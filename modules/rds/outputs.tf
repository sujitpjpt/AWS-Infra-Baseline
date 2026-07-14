output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the RDS master password"
  value       = aws_db_instance.db_instance.master_user_secret[0].secret_arn
}

output "db_instance_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.db_instance.endpoint
}

output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.db_instance.id
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.db_instance.arn
}

output "db_instance_port" {
  description = "Port the RDS instance listens on"
  value       = aws_db_instance.db_instance.port
}

output "db_name" {
  description = "Name of the initial database created on the instance"
  value       = aws_db_instance.db_instance.db_name
}

output "master_username" {
  description = "The master username for the database"
  value       = aws_db_instance.db_instance.username
}
