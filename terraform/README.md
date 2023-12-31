<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.31.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster_alb"></a> [cluster\_alb](#module\_cluster\_alb) | github.com/wenqiglantz/reusable-workflows-modules//terraform/modules/ecs/cluster_alb | main |
| <a name="module_fargate"></a> [fargate](#module\_fargate) | github.com/wenqiglantz/reusable-workflows-modules//terraform/modules/ecs/service_taskdef | main |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.cert](https://registry.terraform.io/providers/hashicorp/aws/5.31.0/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster (up to 255 letters, numbers, hyphens, and underscores) | `string` | `""` | no |
| <a name="input_context_path"></a> [context\_path](#input\_context\_path) | application's path, used for ALB listener rule configuration | `string` | `""` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The CPU size | `string` | `"512"` | no |
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | flag to create new cluster or use existing one | `bool` | `true` | no |
| <a name="input_deploy_env"></a> [deploy\_env](#input\_deploy\_env) | CI injected variable, deployment environment | `string` | `"dev"` | no |
| <a name="input_deploy_repo"></a> [deploy\_repo](#input\_deploy\_repo) | CI injected variable, application's repo name | `string` | `"sharedactions"` | no |
| <a name="input_ecr_repository_name"></a> [ecr\_repository\_name](#input\_ecr\_repository\_name) | The ECR repository name | `string` | `"default"` | no |
| <a name="input_github_repo_owner"></a> [github\_repo\_owner](#input\_github\_repo\_owner) | GitHub repo owner | `string` | `""` | no |
| <a name="input_healthcheck_path"></a> [healthcheck\_path](#input\_healthcheck\_path) | application's health check path | `string` | `""` | no |
| <a name="input_log_group_retention_in_days"></a> [log\_group\_retention\_in\_days](#input\_log\_group\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, etc. | `number` | `7` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The memory size | `string` | `"1024"` | no |
| <a name="input_pipeline_token"></a> [pipeline\_token](#input\_pipeline\_token) | CI injected variable, pipeline token | `string` | `""` | no |
| <a name="input_requester_name"></a> [requester\_name](#input\_requester\_name) | requestor name tag | `string` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | service name, the same as the ECR image name | `string` | n/a | yes |
| <a name="input_service_port_target_group"></a> [service\_port\_target\_group](#input\_service\_port\_target\_group) | application's service port | `number` | `8080` | no |
| <a name="input_service_prefix"></a> [service\_prefix](#input\_service\_prefix) | service prefix to be used in naming resources such as ALB, target group, security group, etc. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_security_group_id"></a> [alb\_security\_group\_id](#output\_alb\_security\_group\_id) | n/a |
| <a name="output_app_test"></a> [app\_test](#output\_app\_test) | n/a |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | n/a |
| <a name="output_ecr_repository_name"></a> [ecr\_repository\_name](#output\_ecr\_repository\_name) | n/a |
| <a name="output_ecs_alb_target_group_arn"></a> [ecs\_alb\_target\_group\_arn](#output\_ecs\_alb\_target\_group\_arn) | n/a |
| <a name="output_ecs_cluster"></a> [ecs\_cluster](#output\_ecs\_cluster) | n/a |
| <a name="output_ecs_service"></a> [ecs\_service](#output\_ecs\_service) | n/a |
| <a name="output_ecs_task_definition"></a> [ecs\_task\_definition](#output\_ecs\_task\_definition) | n/a |
| <a name="output_fargate_task_security_group_id"></a> [fargate\_task\_security\_group\_id](#output\_fargate\_task\_security\_group\_id) | n/a |
<!-- END_TF_DOCS -->