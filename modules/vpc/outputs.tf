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

output "private_data_subnet_ids" {
  description = "The IDs of the private data subnets"
  value       = [for subnet in aws_subnet.private_data_subnet : subnet.id]
}

output "public_subnet_acl" {
  description = "The ID of the public subnet ACL"
  value       = aws_network_acl.public_subnet_acl.id
}

output "private_app_subnet_acl" {
  description = "The ID of the private app subnet ACL"
  value       = aws_network_acl.private_app_subnet_acl.id
}

output "private_data_subnet_acl" {
  description = "The ID of the private data subnet ACL"
  value       = aws_network_acl.private_data_subnet_acl.id
}
