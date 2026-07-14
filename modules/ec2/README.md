# ec2

Provisions EC2 smoke-test instances (one per subnet tier: public, private app) used to validate
the network/IAM foundation end-to-end. Amazon Linux 2023 (SSM agent preinstalled), no key pairs —
all access via SSM Session Manager. Not production compute; the db tier has no EC2 instance since
its subnet has no NAT route by design.

The private app-tier instance boots a minimal Flask app (`templates/app.py`, rendered into
`templates/user_data.sh.tpl` via `templatefile()`) that validates end-to-end DB connectivity:
- `GET /health` — liveness probe for the app process, doesn't touch the database
- `GET /db-check` — fetches the RDS master password from Secrets Manager (once, at boot — never
  passed through user-data in plaintext), connects to Postgres, writes a row to a demo table, and
  returns recent rows so the response shows live database contents rather than just a ping

The app resolves its own AWS region via EC2 instance metadata (IMDSv2) at boot rather than through
a Terraform variable, so this module stays region-agnostic.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_instance.private_app_ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.public_ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_ssm_parameter.al2023_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name, used in resource naming | `string` | n/a | yes |
| <a name="input_private_app_instances"></a> [private\_app\_instances](#input\_private\_app\_instances) | A map of private application EC2 instance configurations, keyed by index | <pre>map(object({<br/>    subnet_id                   = string<br/>    security_group_id           = string<br/>    instance_type               = string<br/>    associate_public_ip_address = bool<br/>  }))</pre> | n/a | yes |
| <a name="input_private_iam_instance_profile_name"></a> [private\_iam\_instance\_profile\_name](#input\_private\_iam\_instance\_profile\_name) | The name of the IAM instance profile to associate with private-app-tier EC2 instances | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name, used in resource naming | `string` | n/a | yes |
| <a name="input_public_iam_instance_profile_name"></a> [public\_iam\_instance\_profile\_name](#input\_public\_iam\_instance\_profile\_name) | The name of the IAM instance profile to associate with public-tier EC2 instances | `string` | n/a | yes |
| <a name="input_public_instances"></a> [public\_instances](#input\_public\_instances) | A map of public EC2 instance configurations, keyed by index | <pre>map(object({<br/>    subnet_id                   = string<br/>    security_group_id           = string<br/>    instance_type               = string<br/>    associate_public_ip_address = bool<br/>  }))</pre> | n/a | yes |
| <a name="input_rds_db_name"></a> [rds\_db\_name](#input\_rds\_db\_name) | Name of the database on the RDS instance | `string` | n/a | yes |
| <a name="input_rds_endpoint"></a> [rds\_endpoint](#input\_rds\_endpoint) | Hostname of the RDS instance the private app-tier instances connect to | `string` | n/a | yes |
| <a name="input_rds_port"></a> [rds\_port](#input\_rds\_port) | Port the RDS instance listens on | `number` | n/a | yes |
| <a name="input_rds_secret_arn"></a> [rds\_secret\_arn](#input\_rds\_secret\_arn) | ARN of the Secrets Manager secret holding the RDS master credentials | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_private_app_instance_ids"></a> [private\_app\_instance\_ids](#output\_private\_app\_instance\_ids) | IDs of the private application EC2 instances |
| <a name="output_public_instance_ids"></a> [public\_instance\_ids](#output\_public\_instance\_ids) | IDs of the public EC2 instances |
<!-- END_TF_DOCS -->
