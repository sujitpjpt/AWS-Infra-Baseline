# Input variables for the remote-state module.
# No defaults are set — the calling environment (envs/dev, envs/prod)
# must always supply these explicitly. This keeps the module generic.

variable "project" {
  description = "Project name, used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name, used in resource naming"
  type        = string
}
