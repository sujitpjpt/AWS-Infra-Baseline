variable "project" {
  description = "Project name, used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name, used in resource naming"
  type        = string
}

variable "rds_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the RDS master password"
  type        = string
}
