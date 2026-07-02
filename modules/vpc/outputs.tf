output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main_vpc.id
}

output "public_subnet_ids" {
  description = "List of IDs for the public subnets"
  value       = aws_subnet.public_subnet
}

output "debug_av_zones" {
  value = local.azs
}

output "debug_eip" {
  value = aws_eip.nat_eip
}

