#!/bin/bash
set -euo pipefail

# Opens an interactive SSM Session Manager shell on an EC2 instance, using the profile/region this
# repo's instances actually live in (envs/dev/versions.tf) instead of whatever the caller's default
# AWS CLI profile/region happen to be — that mismatch is what causes a misleading TargetNotConnected
# error even when the instance and SSM Agent are perfectly healthy.

PROFILE="terraform-dev"
REGION="ca-central-1"

read -rp "Instance ID: " INSTANCE_ID

if [ -z "$INSTANCE_ID" ]; then
  echo "No instance ID entered." >&2
  exit 1
fi

aws ssm start-session --target "$INSTANCE_ID" --profile "$PROFILE" --region "$REGION"
