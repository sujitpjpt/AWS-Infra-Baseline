

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "sujit"
  }
}

# Trust policy allowing EC2 instances (not users or other services) to assume this role.
data "aws_iam_policy_document" "ssm_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Scoped to the specific secret ARN, not "*" — least privilege, only reads the RDS master password.
data "aws_iam_policy_document" "rds_secret_access" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    effect    = "Allow"
    resources = [var.rds_secret_arn]
  }
}

resource "aws_iam_policy" "rds_secret_access" {
  name   = "${var.project}-${var.environment}-rds-secret-access"
  policy = data.aws_iam_policy_document.rds_secret_access.json
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-rds-secret-access"
  })
}

# Role for the private-app-tier EC2 instances (SSM registration + scoped Secrets Manager read) — no public-tier instance exists, the ALB is the public tier's only entry point.
resource "aws_iam_role" "private_instance_role" {
  name               = "${var.project}-${var.environment}-private-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ssm_role.json
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-instance-role"
  })
}

# AWS-managed policy giving the SSM agent permission to register the instance and open Session Manager connections — no key pairs, no open port 22.
resource "aws_iam_role_policy_attachment" "ssm_attach_private" {
  role       = aws_iam_role.private_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "rds_secret_access_private" {
  role       = aws_iam_role.private_instance_role.name
  policy_arn = aws_iam_policy.rds_secret_access.arn
}

# Instance profile is the actual object EC2 attaches — the role above can't be assigned to an instance directly.
resource "aws_iam_instance_profile" "private_instance_profile" {
  name = "${var.project}-${var.environment}-private-instance-profile"
  role = aws_iam_role.private_instance_role.name
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-instance-profile"
  })
}



