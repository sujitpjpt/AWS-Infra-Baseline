variable "project" {
  description = "Project name, used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name, used in resource naming"
  type        = string
}

variable "private_iam_instance_profile_name" {
  description = "The name of the IAM instance profile to associate with private-app-tier EC2 instances"
  type        = string
}

variable "app_port" {
  description = "Port the app tier's Flask process listens on, matches the ALB target group port"
  type        = number
}

variable "private_app_instances" {
  description = "A map of private application EC2 instance configurations, keyed by index"
  type = map(object({
    subnet_id                   = string
    security_group_id           = string
    instance_type               = string
    associate_public_ip_address = bool
  }))
}

variable "rds_endpoint" {
  description = "Hostname of the RDS instance the private app-tier instances connect to"
  type        = string
}

variable "rds_port" {
  description = "Port the RDS instance listens on"
  type        = number
}

variable "rds_db_name" {
  description = "Name of the database on the RDS instance"
  type        = string
}

variable "rds_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the RDS master credentials"
  type        = string
}
