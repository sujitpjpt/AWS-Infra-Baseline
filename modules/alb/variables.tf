variable "project" {
  description = "Project name, used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name, used in resource naming"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "public_sg_id" {
  description = "ID of the security group for the ALB"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the ALB will be deployed"
  type        = string
}

variable "app_port" {
  description = "Port the app tier's Flask process listens on, matches the ALB target group port"
  type        = number
}

variable "target_instance_ids" {
  description = "Map of IDs of the target EC2 instances to attach to the ALB target group, keyed the same as the EC2 module's private_app_instances"
  type        = map(string)
}

variable "health_check_path" {
  description = "Path the ALB target group health check requests, matches the app's process-liveness endpoint"
  type        = string
  default     = "/health"
}
