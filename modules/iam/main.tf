

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

resource "aws_iam_role" "ssm_instance_role" {
  assume_role_policy = data.aws_iam_policy_document.ssm_role.json
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-ssm-instance-role"
  })
}

resource "aws_iam_role_policy_attachment" "ssm-attach" {
  role       = aws_iam_role.ssm_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  role = aws_iam_role.ssm_instance_role.name
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-ssm-instance-profile"
  })
}
