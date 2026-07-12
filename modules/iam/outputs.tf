output "ssm_instance_profile_arn" {
  value       = aws_iam_instance_profile.ssm_instance_profile.arn
  description = "The ARN of the SSM instance profile"
}

output "ssm_instance_profile_name" {
  value       = aws_iam_instance_profile.ssm_instance_profile.name
  description = "The name of the SSM instance profile"
}
