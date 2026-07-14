# rds

Provisions a single-AZ, free-tier eligible Postgres instance (`db.t4g.micro`) used to smoke-test
db-tier connectivity from the app-tier EC2 instance. Not a production database design — Phase 2
(`aws-rds-observability`) adds Multi-AZ and observability on top of this instance rather than
provisioning its own. Master password uses `manage_master_user_password = true` (RDS-managed
secret in Secrets Manager), not a Terraform-generated secret.

<!-- BEGIN_TF_DOCS -->


## Resources

| Name | Type |
| ---- | ---- |
| [aws_db_instance.db_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.db_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | The allocated storage in gigabytes | `number` | `10` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Name of the initial database created on the instance | `string` | `"smoketest"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether to enable deletion protection on the instance | `bool` | `false` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The database engine to use | `string` | `"postgres"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Postgres engine version | `string` | `"16.4"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name, used in resource naming | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | RDS instance class — db.t4g.micro is free-tier eligible (Graviton) | `string` | `"db.t4g.micro"` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | The master username for the database | `string` | `"db_admin"` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Whether to create a multi-AZ RDS instance | `bool` | `false` | no |
| <a name="input_port"></a> [port](#input\_port) | Port the RDS instance listens on | `number` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name, used in resource naming | `string` | n/a | yes |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Security group ID for the RDS instance | `string` | n/a | yes |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Whether to skip the final snapshot on destroy | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | EBS storage type backing the instance | `string` | `"gp2"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the RDS instance | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_master_user_secret_arn"></a> [master\_user\_secret\_arn](#output\_master\_user\_secret\_arn) | ARN of the Secrets Manager secret holding the RDS master password |
<!-- END_TF_DOCS -->
