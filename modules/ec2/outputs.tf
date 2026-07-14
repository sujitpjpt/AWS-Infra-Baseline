output "public_instance_ids" {
  description = "IDs of the public EC2 instances"
  value       = [for instance in aws_instance.public_ec2_instance : instance.id]
}

output "private_app_instance_ids" {
  description = "IDs of the private application EC2 instances"
  value       = [for instance in aws_instance.private_app_ec2_instance : instance.id]
}
