# Root module for the dev environment — calls reusable modules and passes environment-specific values; no env-specific logic lives inside a module.

locals {
  public_instances = {
    for index, subnet_id in module.vpc.public_subnet_ids : index => {
      subnet_id                   = subnet_id
      security_group_id           = module.sg.public_sg_id
      instance_type               = "t3.micro"
      associate_public_ip_address = true
    }
  }
  private_app_instances = {
    for index, subnet_id in module.vpc.private_app_subnet_ids : index => {
      subnet_id                   = subnet_id
      security_group_id           = module.sg.private_app_sg_id
      instance_type               = "t3.micro"
      associate_public_ip_address = false
    }
  }
}

module "remote_state" {
  # Path to the reusable module — two levels up, then into modules/remote-state
  source      = "../../modules/remote-state"
  project     = "aws-infra-baseline"
  environment = "dev"
}

module "vpc" {
  source      = "../../modules/vpc"
  project     = "aws-infra-baseline"
  environment = "dev"
}

module "sg" {
  source      = "../../modules/sg"
  project     = "aws-infra-baseline"
  environment = "dev"
  vpc_id      = module.vpc.vpc_id
  app_port    = module.vpc.vpc_app_port
  db_port     = module.vpc.vpc_db_port
}

module "ec2" {
  source                            = "../../modules/ec2"
  project                           = "aws-infra-baseline"
  environment                       = "dev"
  public_iam_instance_profile_name  = module.iam.public_instance_profile_name
  private_iam_instance_profile_name = module.iam.private_instance_profile_name
  public_instances                  = local.public_instances
  private_app_instances             = local.private_app_instances
  rds_endpoint                      = module.rds.db_instance_address
  rds_port                          = module.rds.db_instance_port
  rds_db_name                       = module.rds.db_name
  rds_secret_arn                    = module.rds.master_user_secret_arn
}

module "rds" {
  source            = "../../modules/rds"
  project           = "aws-infra-baseline"
  environment       = "dev"
  subnet_ids        = module.vpc.private_db_subnet_ids
  security_group_id = module.sg.private_db_sg_id
  port              = module.vpc.vpc_db_port
}

module "iam" {
  source         = "../../modules/iam"
  project        = "aws-infra-baseline"
  environment    = "dev"
  rds_secret_arn = module.rds.master_user_secret_arn
}

