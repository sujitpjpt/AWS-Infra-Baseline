# iam

Provisions IAM roles and instance profiles for the EC2 smoke-test instances. Two separate profiles
enforce least privilege by tier:

- **public** — `AmazonSSMManagedInstanceCore` only (SSM access, no RDS secret access)
- **private** — `AmazonSSMManagedInstanceCore` plus a scoped `secretsmanager:GetSecretValue` policy
  for the RDS-managed master user secret, so only the app-tier instance can read the DB password

No dedicated bastion role — SSM Session Manager is the sole access path, per the no-bastion decision.

<!-- BEGIN_TF_DOCS -->


## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_instance_profile.private_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.rds_secret_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.private_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.rds_secret_access_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_attach_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.rds_secret_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name, used in resource naming | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name, used in resource naming | `string` | n/a | yes |
| <a name="input_rds_secret_arn"></a> [rds\_secret\_arn](#input\_rds\_secret\_arn) | ARN of the Secrets Manager secret holding the RDS master password | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_private_instance_profile_arn"></a> [private\_instance\_profile\_arn](#output\_private\_instance\_profile\_arn) | The ARN of the private-tier instance profile |
| <a name="output_private_instance_profile_name"></a> [private\_instance\_profile\_name](#output\_private\_instance\_profile\_name) | The name of the private-tier instance profile |
<!-- END_TF_DOCS -->
