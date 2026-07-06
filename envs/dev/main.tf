# Root module for the dev environment — calls reusable modules and passes environment-specific values; no env-specific logic lives inside a module.

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
