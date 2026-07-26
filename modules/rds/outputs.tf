output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the RDS master password"
  value       = aws_db_instance.db_instance.master_user_secret[0].secret_arn
}

output "db_instance_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.db_instance.endpoint
}

# Plain hostname, distinct from db_instance_endpoint (which is "host:port") — clients like psycopg2
# take host and port as separate arguments, so this is the value they actually need.
output "db_instance_address" {
  description = "Hostname of the RDS instance, without the port"
  value       = aws_db_instance.db_instance.address
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

output "db_instance_resource_id" {
  description = "The RDS resource ID of the instance"
  value       = aws_db_instance.db_instance.resource_id
}
