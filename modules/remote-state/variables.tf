# No defaults set — the calling environment (envs/dev, envs/prod) must always supply these explicitly, keeping the module generic.

variable "project" {
  description = "Project name, used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name, used in resource naming"
  type        = string
}
