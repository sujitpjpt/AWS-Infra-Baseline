variable "project" {
  description = "Project name, used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name, used in resource naming"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 10
}

variable "engine" {
  description = "The database engine to use"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Postgres engine version"
  type        = string
  default     = "16.4"
}

variable "instance_class" {
  description = "RDS instance class — db.t4g.micro is free-tier eligible (Graviton)"
  type        = string
  default     = "db.t4g.micro"
}

variable "storage_type" {
  description = "EBS storage type backing the instance"
  type        = string
  default     = "gp2"
}

variable "db_name" {
  description = "Name of the initial database created on the instance"
  type        = string
  default     = "smoketest"
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot on destroy"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection on the instance"
  type        = bool
  default     = false
}

variable "master_username" {
  description = "The master username for the database"
  type        = string
  default     = "db_admin"
}

variable "multi_az" {
  description = "Whether to create a multi-AZ RDS instance"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS instance"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the RDS instance"
  type        = string
}

variable "port" {
  description = "Port the RDS instance listens on"
  type        = number
}
