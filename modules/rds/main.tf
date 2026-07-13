locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "sujit"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids = var.subnet_ids
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-rds-subnet-group"
  })
}

resource "aws_db_instance" "db_instance" {
  allocated_storage           = var.allocated_storage
  engine                      = var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  storage_type                = var.storage_type
  db_name                     = var.db_name
  manage_master_user_password = true
  username                    = var.master_username
  skip_final_snapshot         = var.skip_final_snapshot
  deletion_protection         = var.deletion_protection
  storage_encrypted           = true
  publicly_accessible         = false
  multi_az                    = var.multi_az
  vpc_security_group_ids      = [var.security_group_id]
  db_subnet_group_name        = aws_db_subnet_group.db_subnet_group.name
  port                        = var.port
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-rds-instance"
  })
}
