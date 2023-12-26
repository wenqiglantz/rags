output "ecs_cluster" {
  value = module.fargate.ecs_cluster
}

output "ecs_service" {
  value = module.fargate.ecs_service
}

output "ecs_task_definition" {
  value = module.fargate.ecs_task_definition
}

output "container_name" {
  value = module.fargate.container_name
}

output "ecr_repository_name" {
  value = module.fargate.ecr_repository_name
}

output "app_test" {
  value = module.fargate.app_test
}

output "ecs_alb_target_group_arn" {
  value = module.cluster_alb.ecs_alb_target_group_arn
}

output "alb_security_group_id" {
  value = module.cluster_alb.alb_security_group_id
}

output "fargate_task_security_group_id" {
  value = module.fargate.fargate_task_security_group_id
}
