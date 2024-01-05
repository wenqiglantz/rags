<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.31.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 5.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.31.0 |
| <a name="provider_github"></a> [github](#provider\_github) | 5.42.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | 9.4.0 |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | terraform-aws-modules/ecr/aws | n/a |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | terraform-aws-modules/ecs/aws | 5.7.4 |
| <a name="module_log_bucket"></a> [log\_bucket](#module\_log\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 3.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_service_discovery_http_namespace.this](https://registry.terraform.io/providers/hashicorp/aws/5.31.0/docs/resources/service_discovery_http_namespace) | resource |
| [github_actions_environment_variable.container_name](https://registry.terraform.io/providers/integrations/github/5.42.0/docs/resources/actions_environment_variable) | resource |
| [github_actions_environment_variable.ecr_repository_name](https://registry.terraform.io/providers/integrations/github/5.42.0/docs/resources/actions_environment_variable) | resource |
| [github_actions_environment_variable.ecs_cluster](https://registry.terraform.io/providers/integrations/github/5.42.0/docs/resources/actions_environment_variable) | resource |
| [github_actions_environment_variable.ecs_service](https://registry.terraform.io/providers/integrations/github/5.42.0/docs/resources/actions_environment_variable) | resource |
| [github_actions_environment_variable.ecs_task_definition](https://registry.terraform.io/providers/integrations/github/5.42.0/docs/resources/actions_environment_variable) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/5.31.0/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/5.31.0/docs/data-sources/caller_identity) | data source |
| [aws_ssm_parameter.cert](https://registry.terraform.io/providers/hashicorp/aws/5.31.0/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster (up to 255 letters, numbers, hyphens, and underscores) | `string` | `""` | no |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | The container CPU size | `string` | `"512"` | no |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | The container memory size | `string` | `"1024"` | no |
| <a name="input_deploy_env"></a> [deploy\_env](#input\_deploy\_env) | deployment environment | `string` | `"dev"` | no |
| <a name="input_deploy_repo"></a> [deploy\_repo](#input\_deploy\_repo) | application's repo name | `string` | n/a | yes |
| <a name="input_ecr_repository_name"></a> [ecr\_repository\_name](#input\_ecr\_repository\_name) | The ECR repository name | `string` | `"default"` | no |
| <a name="input_github_repo_owner"></a> [github\_repo\_owner](#input\_github\_repo\_owner) | GitHub repo owner | `string` | `""` | no |
| <a name="input_healthcheck_path"></a> [healthcheck\_path](#input\_healthcheck\_path) | application's health check path | `string` | `""` | no |
| <a name="input_pipeline_token"></a> [pipeline\_token](#input\_pipeline\_token) | CI injected variable, pipeline token | `string` | `""` | no |
| <a name="input_requester_name"></a> [requester\_name](#input\_requester\_name) | requestor name tag | `string` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | service name, the same as the ECR image name | `string` | n/a | yes |
| <a name="input_service_port"></a> [service\_port](#input\_service\_port) | application's service port | `number` | `8501` | no |
| <a name="input_service_prefix"></a> [service\_prefix](#input\_service\_prefix) | service prefix to be used in naming resources such as ALB, target group, security group, etc. | `string` | n/a | yes |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | The task CPU size | `string` | `"512"` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | The task memory size | `string` | `"1024"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block of the vpc | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of the vpc | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster"></a> [ecs\_cluster](#output\_ecs\_cluster) | n/a |
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | Full ARN of the repository |
| <a name="output_repository_registry_id"></a> [repository\_registry\_id](#output\_repository\_registry\_id) | The registry ID where the repository was created |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | The URL of the repository |
| <a name="output_services"></a> [services](#output\_services) | n/a |
<!-- END_TF_DOCS -->