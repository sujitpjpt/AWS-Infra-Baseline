# Creates the S3 bucket for Terraform state — apply this with LOCAL state first, then add the backend block and run terraform init -migrate-state.

resource "aws_s3_bucket" "state" {
  bucket = "${var.project}-${var.environment}-tfstate"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "sujit"
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypts state files at rest using AES256 — state can contain sensitive values, so encryption is non-negotiable.
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# State files must never be publicly readable — they can expose infrastructure secrets.
resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning keeps every historical state file, so without expiration old versions accumulate forever.
# This bounds storage and cleans up delete markers left behind by terraform state operations.
resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "expire-noncurrent-state-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    expiration {
      expired_object_delete_marker = true
    }
  }
}
