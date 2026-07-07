data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # AZ count derived from public subnet CIDRs — public/private lists must stay the same length (1 subnet per AZ each).
  az_count = length(var.public_subnet_cidrs)
  # sort() before slice() keeps the chosen AZs deterministic, since aws_availability_zones order is not guaranteed.
  azs = slice(sort(data.aws_availability_zones.available.names), 0, local.az_count)

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "sujit"
  }

  # Maps each AZ to its own NAT gateway ID so private route tables route egress through the same-AZ NAT (avoids cross-AZ transfer cost).
  az_gw_mapping = { for key, value in aws_subnet.public_subnet : value.availability_zone => aws_nat_gateway.nat_gw[key].id }
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-vpc"
  })
}

# for_each (not count) keys subnets by CIDR, so reordering the CIDR list won't force unrelated subnets to be destroyed/recreated.
resource "aws_subnet" "public_subnet" {
  for_each          = zipmap(var.public_subnet_cidrs, local.azs)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = each.key
  availability_zone = each.value
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-public-${each.value}"
  })
}

resource "aws_subnet" "private_app_subnet" {
  for_each          = zipmap(var.private_app_subnet_cidrs, local.azs)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = each.key
  availability_zone = each.value
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-${each.value}"
  })
}

resource "aws_subnet" "private_data_subnet" {
  for_each          = zipmap(var.private_data_subnet_cidrs, local.azs)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = each.key
  availability_zone = each.value
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-${each.value}"
  })
}

resource "aws_internet_gateway" "main_gateway" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-gw"
  })
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gateway.id
  }
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-public-route-table"
  })
}

resource "aws_route_table_association" "public_association" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

# One EIP + NAT gateway per public subnet (per AZ) instead of one shared NAT gateway — costs more but avoids a cross-AZ single point of failure and transfer charges.
resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.public_subnet
  domain   = "vpc"
  tags     = merge(local.common_tags, { Name = "${var.project}-${var.environment}-nat-${each.value.availability_zone}" })
}

resource "aws_nat_gateway" "nat_gw" {
  for_each      = aws_subnet.public_subnet
  subnet_id     = each.value.id
  allocation_id = aws_eip.nat_eip[each.key].id
  tags          = merge(local.common_tags, { Name = "${var.project}-${var.environment}-nat-${each.value.availability_zone}" })
  depends_on    = [aws_internet_gateway.main_gateway]
}

# One route table per private subnet (not shared) so each can route to the NAT gateway in its own AZ via az_gw_mapping.
resource "aws_route_table" "private_app_route_table" {
  for_each = aws_subnet.private_app_subnet
  vpc_id   = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.az_gw_mapping[each.value.availability_zone]
  }
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-app-route-table-${each.value.availability_zone}"
  })
}

# Deliberately has no `route` block — only the implicit local VPC route exists, matching the NACL above (no 140/150 egress rules).
resource "aws_route_table" "private_data_route_table" {
  for_each = aws_subnet.private_data_subnet
  vpc_id   = aws_vpc.main_vpc.id
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-data-route-table-${each.value.availability_zone}"
  })
}


resource "aws_route_table_association" "private_app_association" {
  for_each       = aws_subnet.private_app_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_app_route_table[each.key].id
}

resource "aws_route_table_association" "private_data_association" {
  for_each       = aws_subnet.private_data_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_data_route_table[each.key].id
}

resource "aws_network_acl" "public_subnet_acl" {
  vpc_id     = aws_vpc.main_vpc.id
  subnet_ids = [for s in aws_subnet.public_subnet : s.id]

  # NACLs are stateless, so every allowed request needs an explicit rule for its response traffic (the ephemeral port ranges below).

  # Allow inbound HTTP from anywhere — typically just a redirect to HTTPS.
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Allow inbound HTTPS from anywhere — the real entry point for client traffic hitting the ALB.
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Allow inbound ephemeral ports from anywhere — carries reply traffic for connections this subnet itself initiates (e.g. the ALB's own outbound calls), since NACLs evaluate each direction independently.
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Allow outbound HTTP to anywhere — reply path for inbound HTTP (rule 100) plus any outbound HTTP calls from this subnet.
  egress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Allow outbound HTTPS to anywhere — reply path for inbound HTTPS (rule 110) plus any outbound HTTPS calls from this subnet.
  egress {
    protocol   = "tcp"
    rule_no    = 140
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Allow outbound traffic to the app tier on app_port, scoped to the VPC CIDR — this is the ALB forwarding requests to the app subnet.
  egress {
    protocol   = "tcp"
    rule_no    = 150
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = var.app_port
    to_port    = var.app_port
  }

  # Allow outbound ephemeral ports to anywhere — reply path for inbound requests this subnet is servicing as a "server" (rules 100/110).
  egress {
    protocol   = "tcp"
    rule_no    = 160
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-public-subnet-acl"
  })
}

resource "aws_network_acl" "private_app_subnet_acl" {
  vpc_id     = aws_vpc.main_vpc.id
  subnet_ids = [for s in aws_subnet.private_app_subnet : s.id]

  # Allow inbound app traffic from the public subnet only, on app_port — this is the ALB forwarding requests in.
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = var.app_port
    to_port    = var.app_port
  }

  # Allow inbound ephemeral ports from anywhere — reply path for DB connections (rule 120) and internet egress (140/150) this subnet initiates; must stay 0.0.0.0/0, not var.vpc_cidr, to also carry that return traffic.
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Allow outbound traffic to the data tier on db_port, scoped to the VPC CIDR — the app tier querying the database.
  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = var.db_port
    to_port    = var.db_port
  }

  # Allow outbound ephemeral ports within the VPC — reply path for inbound app traffic this subnet is servicing as a "server" (rule 100).
  egress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 1024
    to_port    = 65535
  }

  # Allow outbound HTTP to the internet (via NAT) — e.g. package installs, OS updates.
  egress {
    protocol   = "tcp"
    rule_no    = 140
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Allow outbound HTTPS to the internet (via NAT) — e.g. external API calls, package registries.
  egress {
    protocol   = "tcp"
    rule_no    = 150
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-app-subnet-acl"
  })
}

resource "aws_network_acl" "private_data_subnet_acl" {
  vpc_id     = aws_vpc.main_vpc.id
  subnet_ids = [for s in aws_subnet.private_data_subnet : s.id]

  # Allow inbound database traffic from the app tier only, on db_port — no other subnet or the internet can reach this.
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = var.db_port
    to_port    = var.db_port
  }

  # Allow outbound ephemeral ports within the VPC only — reply path for inbound DB connections (rule 100); no internet-facing rules exist on this NACL since the data tier never initiates outbound traffic.
  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 1024
    to_port    = 65535
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-data-subnet-acl"
  })
}
