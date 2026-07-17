output "private_app_instance_ids" {
  description = "IDs of the private application EC2 instances, keyed the same as var.private_app_instances"
  value       = { for key, instance in aws_instance.private_app_ec2_instance : key => instance.id }
}
