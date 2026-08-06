# envs/dev

The dev environment root module — the only environment in use for this portfolio project
(see `TODO`/`DECIDED` notes on `envs/prod` in the project's private dev log). Wires together
`modules/vpc`, `modules/sg`, `modules/iam`, `modules/ec2`, `modules/rds`, `modules/alb`, and
`modules/remote-state` with environment-specific values (`project = "aws-infra-baseline"`,
`environment = "dev"`, region `ca-central-1`). No resources are defined directly here beyond
module wiring and the `private_app_instances` local — all environment-specific logic lives in
this folder, never inside a module.

`outputs.tf` in this folder is the **contract** for anything reading this repo's state via
`terraform_remote_state`. Treat renames/removals here as breaking changes.

## Usage

```bash
cd envs/dev
terraform init
terraform plan
terraform apply
```

The S3 state bucket referenced in the `backend "s3"` block (`versions.tf`) must exist before
`terraform init` can succeed — it is provisioned by `module.remote_state`, so on a first-ever
run, apply that module (or bootstrap the bucket manually) before switching to the S3 backend.

Credentials come from the standard AWS provider chain — `AWS_PROFILE` locally, an OIDC-assumed
role (`AWS_ROLE_ARN` secret) in GitHub Actions. No long-lived keys anywhere.

<!-- BEGIN_TF_DOCS -->


## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN of the public ALB |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS name of the public ALB, used to reach the app tier |
| <a name="output_alb_zone_id"></a> [alb\_zone\_id](#output\_alb\_zone\_id) | Route53 hosted zone ID of the ALB, needed for an alias record |
| <a name="output_db_instance_address"></a> [db\_instance\_address](#output\_db\_instance\_address) | Hostname of the RDS instance, without the port |
| <a name="output_db_instance_arn"></a> [db\_instance\_arn](#output\_db\_instance\_arn) | ARN of the RDS instance |
| <a name="output_db_instance_endpoint"></a> [db\_instance\_endpoint](#output\_db\_instance\_endpoint) | Endpoint of the RDS instance (host:port) |
| <a name="output_db_instance_id"></a> [db\_instance\_id](#output\_db\_instance\_id) | ID of the RDS instance |
| <a name="output_db_instance_port"></a> [db\_instance\_port](#output\_db\_instance\_port) | Port the RDS instance listens on |
| <a name="output_db_instance_resource_id"></a> [db\_instance\_resource\_id](#output\_db\_instance\_resource\_id) | The RDS resource ID (DbiResourceId) of the instance, needed by Performance Insights' GetResourceMetrics API |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | Name of the initial database created on the instance |
| <a name="output_listener_arn"></a> [listener\_arn](#output\_listener\_arn) | ARN of the HTTP listener |
| <a name="output_master_user_secret_arn"></a> [master\_user\_secret\_arn](#output\_master\_user\_secret\_arn) | ARN of the Secrets Manager secret holding the RDS master password |
| <a name="output_master_username"></a> [master\_username](#output\_master\_username) | The master username for the database |
| <a name="output_private_app_instance_ids"></a> [private\_app\_instance\_ids](#output\_private\_app\_instance\_ids) | IDs of the private app-tier EC2 smoke-test instances |
| <a name="output_private_app_sg_id"></a> [private\_app\_sg\_id](#output\_private\_app\_sg\_id) | The ID of the private app security group |
| <a name="output_private_app_subnet_ids"></a> [private\_app\_subnet\_ids](#output\_private\_app\_subnet\_ids) | The IDs of the private app subnets |
| <a name="output_private_db_sg_id"></a> [private\_db\_sg\_id](#output\_private\_db\_sg\_id) | The ID of the private db security group |
| <a name="output_private_db_subnet_ids"></a> [private\_db\_subnet\_ids](#output\_private\_db\_subnet\_ids) | The IDs of the private db subnets |
| <a name="output_private_instance_profile_arn"></a> [private\_instance\_profile\_arn](#output\_private\_instance\_profile\_arn) | The ARN of the private-tier instance profile |
| <a name="output_private_instance_profile_name"></a> [private\_instance\_profile\_name](#output\_private\_instance\_profile\_name) | The name of the private-tier instance profile |
| <a name="output_public_sg_id"></a> [public\_sg\_id](#output\_public\_sg\_id) | The ID of the public security group |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | The IDs of the public subnets |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN of the app-tier target group |
| <a name="output_tfstate_bucket_arn"></a> [tfstate\_bucket\_arn](#output\_tfstate\_bucket\_arn) | ARN of the S3 state bucket, used for IAM policies granting CI/CD access to state |
| <a name="output_tfstate_bucket_name"></a> [tfstate\_bucket\_name](#output\_tfstate\_bucket\_name) | Name of the S3 bucket used for Terraform state |
| <a name="output_vpc_app_port"></a> [vpc\_app\_port](#output\_vpc\_app\_port) | The port the app tier listens on |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_db_port"></a> [vpc\_db\_port](#output\_vpc\_db\_port) | The port the db tier listens on |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END_TF_DOCS -->
