# ec2

Provisions EC2 smoke-test instances (one per subnet tier: public, private app) used to validate
the network/IAM foundation end-to-end. Amazon Linux 2023 (SSM agent preinstalled), no key pairs —
all access via SSM Session Manager. Not production compute; the db tier has no EC2 instance since
its subnet has no NAT route by design.

<!-- BEGIN_TF_DOCS -->


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

## Outputs

No outputs.
<!-- END_TF_DOCS -->
