variable "project" {
  description = "Project name, used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name, used in resource naming"
  type        = string
}

variable "public_iam_instance_profile_name" {
  description = "The name of the IAM instance profile to associate with public-tier EC2 instances"
  type        = string
}

variable "private_iam_instance_profile_name" {
  description = "The name of the IAM instance profile to associate with private-app-tier EC2 instances"
  type        = string
}

variable "public_instances" {
  description = "A map of public EC2 instance configurations, keyed by index"
  type = map(object({
    subnet_id                   = string
    security_group_id           = string
    instance_type               = string
    associate_public_ip_address = bool
  }))
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
