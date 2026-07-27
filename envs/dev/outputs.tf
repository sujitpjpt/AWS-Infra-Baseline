# Root-level outputs — the actual contract downstream repos read via terraform_remote_state.

# --- VPC ---

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "The IDs of the private app subnets"
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "The IDs of the private db subnets"
  value       = module.vpc.private_db_subnet_ids
}

output "vpc_app_port" {
  description = "The port the app tier listens on"
  value       = module.vpc.vpc_app_port
}

output "vpc_db_port" {
  description = "The port the db tier listens on"
  value       = module.vpc.vpc_db_port
}

# --- Security groups ---

output "public_sg_id" {
  description = "The ID of the public security group"
  value       = module.sg.public_sg_id
}

output "private_app_sg_id" {
  description = "The ID of the private app security group"
  value       = module.sg.private_app_sg_id
}

output "private_db_sg_id" {
  description = "The ID of the private db security group"
  value       = module.sg.private_db_sg_id
}

# --- IAM ---

output "private_instance_profile_arn" {
  description = "The ARN of the private-tier instance profile"
  value       = module.iam.private_instance_profile_arn
}

output "private_instance_profile_name" {
  description = "The name of the private-tier instance profile"
  value       = module.iam.private_instance_profile_name
}

# --- RDS ---

output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = module.rds.db_instance_id
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = module.rds.db_instance_arn
}

output "db_instance_address" {
  description = "Hostname of the RDS instance, without the port"
  value       = module.rds.db_instance_address
}

output "db_instance_endpoint" {
  description = "Endpoint of the RDS instance (host:port)"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_port" {
  description = "Port the RDS instance listens on"
  value       = module.rds.db_instance_port
}

output "db_name" {
  description = "Name of the initial database created on the instance"
  value       = module.rds.db_name
}

output "master_username" {
  description = "The master username for the database"
  value       = module.rds.master_username
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the RDS master password"
  value       = module.rds.master_user_secret_arn
}

output "db_instance_resource_id" {
  description = "The RDS resource ID (DbiResourceId) of the instance, needed by Performance Insights' GetResourceMetrics API"
  value       = module.rds.db_instance_resource_id
}

# --- EC2 ---

output "private_app_instance_ids" {
  description = "IDs of the private app-tier EC2 smoke-test instances"
  value       = module.ec2.private_app_instance_ids
}

# --- ALB ---

output "alb_arn" {
  description = "ARN of the public ALB"
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "DNS name of the public ALB, used to reach the app tier"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Route53 hosted zone ID of the ALB, needed for an alias record"
  value       = module.alb.alb_zone_id
}

output "target_group_arn" {
  description = "ARN of the app-tier target group"
  value       = module.alb.target_group_arn
}

output "listener_arn" {
  description = "ARN of the HTTP listener"
  value       = module.alb.listener_arn
}

# --- Remote state ---

output "tfstate_bucket_name" {
  description = "Name of the S3 bucket used for Terraform state"
  value       = module.remote_state.bucket_name
}

output "tfstate_bucket_arn" {
  description = "ARN of the S3 state bucket, used for IAM policies granting CI/CD access to state"
  value       = module.remote_state.bucket_arn
}
