output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main_vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = [for subnet in aws_subnet.public_subnet : subnet.id]
}

output "private_app_subnet_ids" {
  description = "The IDs of the private app subnets"
  value       = [for subnet in aws_subnet.private_app_subnet : subnet.id]
}

output "private_db_subnet_ids" {
  description = "The IDs of the private db subnets"
  value       = [for subnet in aws_subnet.private_db_subnet : subnet.id]
}

output "public_subnet_acl" {
  description = "The ID of the public subnet ACL"
  value       = aws_network_acl.public_subnet_acl.id
}

output "private_app_subnet_acl" {
  description = "The ID of the private app subnet ACL"
  value       = aws_network_acl.private_app_subnet_acl.id
}

output "private_db_subnet_acl" {
  description = "The ID of the private db subnet ACL"
  value       = aws_network_acl.private_db_subnet_acl.id
}

output "vpc_app_port" {
  description = "The port the app tier listens on"
  value       = var.app_port
}

output "vpc_db_port" {
  description = "The port the db tier listens on"
  value       = var.db_port
}
