terraform {
  # ~> 1.15.6 allows patch releases (1.15.7, 1.15.8) but not minor bumps (1.16.x), keeping CI and local environments in sync.
  required_version = "~> 1.15.6"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # ~> 5.0 allows any 5.x patch but not 6.x — pessimistic constraint
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "aws-infra-baseline-dev-tfstate"
    key          = "dev/terraform.tfstate"
    region       = "ca-central-1"
    encrypt      = true
    use_lockfile = true
  }
}

# Region is set here at the provider level, not inside modules, so modules remain region-agnostic and reusable.
# No hardcoded profile — credentials come from the standard AWS chain (env vars in CI via OIDC, AWS_PROFILE locally).
provider "aws" {
  region = "ca-central-1"
}
