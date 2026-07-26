output "public_sg_id" {
  value       = aws_security_group.public_sg.id
  description = "The ID of the public security group"
}

output "private_app_sg_id" {
  value       = aws_security_group.private_app_sg.id
  description = "The ID of the private app security group"
}

output "private_db_sg_id" {
  value       = aws_security_group.private_db_sg.id
  description = "The ID of the private db security group"
}
