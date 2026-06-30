# Root module for the dev environment.
# This is where you call reusable modules and pass environment-specific values.
# No environment-specific logic ever lives inside a module — only here.

module "remote_state" {
  # Path to the reusable module — two levels up, then into modules/remote-state
  source      = "../../modules/remote-state"
  project     = "aws-infra-baseline" 
  environment = "dev"
}
