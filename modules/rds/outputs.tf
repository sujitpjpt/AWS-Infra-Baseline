output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the RDS master password"
  value       = aws_db_instance.db_instance.master_user_secret[0].secret_arn
}
