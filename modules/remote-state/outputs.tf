# Outputs expose values from this module to the calling environment.
# bucket_name is needed when writing the backend block after bootstrapping.
# bucket_arn is needed later when writing IAM policies to grant CI/CD access to state.

output "bucket_name" {
  description = "Name of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.state.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 state bucket, used for IAM policies"
  value       = aws_s3_bucket.state.arn
}
