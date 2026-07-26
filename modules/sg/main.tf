locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "sujit"
  }
}

# Public tier — fronts the app (e.g. ALB). Only this SG is reachable directly from the internet.
resource "aws_security_group" "public_sg" {
  description = "Public subnet security group"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-public-sg"
  })
}

# Allow inbound HTTP from anywhere — typically just a redirect to HTTPS, never the app's actual traffic.
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Allow inbound HTTPS from anywhere — the real entry point for client traffic.
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# Only egress the public tier needs: forward decrypted traffic to the app tier on app_port. Everything else is denied.
resource "aws_vpc_security_group_egress_rule" "public_to_app_tier" {
  security_group_id            = aws_security_group.public_sg.id
  referenced_security_group_id = aws_security_group.private_app_sg.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
}

# App tier — only reachable from the public tier, never directly from the internet.
resource "aws_security_group" "private_app_sg" {
  description = "Private App subnet security group"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-app-sg"
  })
}

# Allow inbound app traffic only from the public tier's SG — not from a CIDR, so only resources actually in public_sg can reach this tier.
resource "aws_vpc_security_group_ingress_rule" "public_to_app" {
  security_group_id            = aws_security_group.private_app_sg.id
  referenced_security_group_id = aws_security_group.public_sg.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
}

# Allow the app tier to reach the database tier on db_port — SG-to-SG reference, not a CIDR, so only this tier can reach the DB.
resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.private_app_sg.id
  referenced_security_group_id = aws_security_group.private_db_sg.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
}

# Allow outbound HTTP — needed for the app tier's own internet-bound calls (e.g. package installs) via the NAT gateway.
resource "aws_vpc_security_group_egress_rule" "http_out" {
  security_group_id = aws_security_group.private_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Allow outbound HTTPS — needed for the app tier's own internet-bound calls (e.g. external APIs, package registries) via the NAT gateway.
resource "aws_vpc_security_group_egress_rule" "https_out" {
  security_group_id = aws_security_group.private_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Data tier — only reachable from the app tier; no egress rules needed since SGs are stateful and reply traffic is automatic.
resource "aws_security_group" "private_db_sg" {
  description = "Private DB subnet security group"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-db-sg"
  })
}

# Allow inbound database traffic only from the app tier's SG — the database is never reachable from the public tier or the internet.
resource "aws_vpc_security_group_ingress_rule" "database_access" {
  security_group_id            = aws_security_group.private_db_sg.id
  referenced_security_group_id = aws_security_group.private_app_sg.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
}
