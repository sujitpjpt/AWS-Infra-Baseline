

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "sujit"
  }
}

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

data "aws_iam_policy_document" "rds_secret_access" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    effect    = "Allow"
    resources = [var.rds_secret_arn]
  }
}

resource "aws_iam_policy" "rds_secret_access" {
  policy = data.aws_iam_policy_document.rds_secret_access.json
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-rds-secret-access"
  })
}

resource "aws_iam_role" "public_instance_role" {
  assume_role_policy = data.aws_iam_policy_document.ssm_role.json
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-public-instance-role"
  })
}

resource "aws_iam_role" "private_instance_role" {
  assume_role_policy = data.aws_iam_policy_document.ssm_role.json
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-instance-role"
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach_public" {
  role       = aws_iam_role.public_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm_attach_private" {
  role       = aws_iam_role.private_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "rds_secret_access_private" {
  role       = aws_iam_role.private_instance_role.name
  policy_arn = aws_iam_policy.rds_secret_access.arn
}

resource "aws_iam_instance_profile" "public_instance_profile" {
  role = aws_iam_role.public_instance_role.name
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-public-instance-profile"
  })
}

resource "aws_iam_instance_profile" "private_instance_profile" {
  role = aws_iam_role.private_instance_role.name
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-instance-profile"
  })
}



