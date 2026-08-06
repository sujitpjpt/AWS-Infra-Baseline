# vpc

Provisions the VPC, public/private subnets across multiple AZs, internet gateway, NAT gateway,
and route tables that form the network foundation for this repo. Downstream modules (sg, ec2, rds, iam)
consume its outputs.

<!-- BEGIN_TF_DOCS -->


## Resources

| Name | Type |
| ---- | ---- |
| [aws_eip.nat_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.main_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat_gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.private_app_subnet_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.private_db_subnet_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.public_subnet_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_route_table.private_app_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private_db_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private_app_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_db_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private_app_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_db_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_app_port"></a> [app\_port](#input\_app\_port) | Port the app tier listens on, reached from the ALB in the public subnet | `number` | `8080` | no |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | Port the db tier listens on (5432 for Postgres, 3306 for MySQL) | `number` | `5432` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name, used in resource naming | `string` | n/a | yes |
| <a name="input_private_app_subnet_cidrs"></a> [private\_app\_subnet\_cidrs](#input\_private\_app\_subnet\_cidrs) | List of CIDR blocks for private subnets, one per AZ | `list(string)` | <pre>[<br/>  "10.0.10.0/24",<br/>  "10.0.20.0/24"<br/>]</pre> | no |
| <a name="input_private_db_subnet_cidrs"></a> [private\_db\_subnet\_cidrs](#input\_private\_db\_subnet\_cidrs) | List of CIDR blocks for private db-tier subnets, one per AZ | `list(string)` | <pre>[<br/>  "10.0.30.0/24",<br/>  "10.0.40.0/24"<br/>]</pre> | no |
| <a name="input_project"></a> [project](#input\_project) | Project name, used in resource naming | `string` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | List of CIDR blocks for public subnets, one per AZ | `list(string)` | <pre>[<br/>  "10.0.1.0/24",<br/>  "10.0.2.0/24"<br/>]</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_private_app_subnet_acl"></a> [private\_app\_subnet\_acl](#output\_private\_app\_subnet\_acl) | The ID of the private app subnet ACL |
| <a name="output_private_app_subnet_ids"></a> [private\_app\_subnet\_ids](#output\_private\_app\_subnet\_ids) | The IDs of the private app subnets |
| <a name="output_private_db_subnet_acl"></a> [private\_db\_subnet\_acl](#output\_private\_db\_subnet\_acl) | The ID of the private db subnet ACL |
| <a name="output_private_db_subnet_ids"></a> [private\_db\_subnet\_ids](#output\_private\_db\_subnet\_ids) | The IDs of the private db subnets |
| <a name="output_public_subnet_acl"></a> [public\_subnet\_acl](#output\_public\_subnet\_acl) | The ID of the public subnet ACL |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | The IDs of the public subnets |
| <a name="output_vpc_app_port"></a> [vpc\_app\_port](#output\_vpc\_app\_port) | The port the app tier listens on |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_db_port"></a> [vpc\_db\_port](#output\_vpc\_db\_port) | The port the db tier listens on |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END_TF_DOCS -->
