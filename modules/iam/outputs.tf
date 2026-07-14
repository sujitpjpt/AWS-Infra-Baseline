output "public_instance_profile_arn" {
  value       = aws_iam_instance_profile.public_instance_profile.arn
  description = "The ARN of the public-tier instance profile"
}

output "public_instance_profile_name" {
  value       = aws_iam_instance_profile.public_instance_profile.name
  description = "The name of the public-tier instance profile"
}

output "private_instance_profile_arn" {
  value       = aws_iam_instance_profile.private_instance_profile.arn
  description = "The ARN of the private-tier instance profile"
}

output "private_instance_profile_name" {
  value       = aws_iam_instance_profile.private_instance_profile.name
  description = "The name of the private-tier instance profile"
}
