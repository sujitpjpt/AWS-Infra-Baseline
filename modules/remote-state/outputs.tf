# bucket_name is needed for the backend block after bootstrapping; bucket_arn is needed later for IAM policies granting CI/CD access to state.

output "bucket_name" {
  description = "Name of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.state.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 state bucket, used for IAM policies"
  value       = aws_s3_bucket.state.arn
}
