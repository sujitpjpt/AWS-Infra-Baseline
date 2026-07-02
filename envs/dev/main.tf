# Root module for the dev environment.
# This is where you call reusable modules and pass environment-specific values.
# No environment-specific logic ever lives inside a module — only here.

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

# output "az_debug" {
#   value = module.vpc.debug_av_zones
# }
# output "debug_public_subnet_ids" {
#   value = module.vpc.public_subnet_ids
# }
output "debug_eip" {
  value = module.vpc.debug_eip
}
