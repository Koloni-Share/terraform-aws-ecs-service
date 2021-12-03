# AWS ECS service terraform module

This module creates and manages resources needed to deploy a service to ECS+Fargate.
To manage a deployment, push an image to the ECR repo exported by this module and change the
service_version variable to match the tag of that image.

## Usage

Configure pre-commit hooks immediately after cloning the repository: `pre-commit install`

If you need, install the following tools to make this work:

* [pre-commit](https://pre-commit.com/)
* [terraform-docs](https://terraform-docs.io/)


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.68.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_service"></a> [service](#module\_service) | cn-terraform/ecs-fargate-service/aws | 2.0.16 |
| <a name="module_taskdef"></a> [taskdef](#module\_taskdef) | ./modules/taskdef | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | n/a | `string` | n/a | yes |
| <a name="input_cluster_arn"></a> [cluster\_arn](#input\_cluster\_arn) | n/a | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_custom_iam_policies"></a> [custom\_iam\_policies](#input\_custom\_iam\_policies) | n/a | `list(string)` | `[]` | no |
| <a name="input_environment_secrets"></a> [environment\_secrets](#input\_environment\_secrets) | n/a | `map(string)` | `{}` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | n/a | `map(string)` | `{}` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | n/a | `string` | `"/"` | no |
| <a name="input_lb_internal"></a> [lb\_internal](#input\_lb\_internal) | n/a | `bool` | `false` | no |
| <a name="input_lb_ip_address_type"></a> [lb\_ip\_address\_type](#input\_lb\_ip\_address\_type) | n/a | `string` | `"dualstack"` | no |
| <a name="input_outbound_sg_id"></a> [outbound\_sg\_id](#input\_outbound\_sg\_id) | n/a | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | n/a | `string` | n/a | yes |
| <a name="input_service_version"></a> [service\_version](#input\_service\_version) | n/a | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repo_name"></a> [ecr\_repo\_name](#output\_ecr\_repo\_name) | n/a |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | n/a |
| <a name="output_lb_zone_id"></a> [lb\_zone\_id](#output\_lb\_zone\_id) | n/a |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | n/a |
