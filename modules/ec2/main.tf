data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "sujit"
  }
}

resource "aws_instance" "public_ec2_instance" {
  for_each                    = var.public_instances
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = [each.value.security_group_id]
  associate_public_ip_address = each.value.associate_public_ip_address
  iam_instance_profile        = var.iam_instance_profile_name

  root_block_device {
    encrypted = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-ec2-public-${each.key}"
  })
}

resource "aws_instance" "private_app_ec2_instance" {
  for_each                    = var.private_app_instances
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = [each.value.security_group_id]
  associate_public_ip_address = each.value.associate_public_ip_address
  iam_instance_profile        = var.iam_instance_profile_name

  root_block_device {
    encrypted = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-ec2-private-app-${each.key}"
  })
}
