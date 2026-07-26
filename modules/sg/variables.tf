variable "project" {
  description = "Project name, used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name, used in resource naming"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC these security groups belong to"
  type        = string
}


variable "app_port" {
  description = "Port the app tier listens on, reached from the ALB in the public subnet"
  type        = number
}

variable "db_port" {
  description = "Port the db tier listens on (5432 for Postgres, 3306 for MySQL)"
  type        = number
}
