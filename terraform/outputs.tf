output "ecs_cluster" {
  value = module.ecs.cluster_name
}

output "services" {
  value = module.ecs.services
}

output "repository_arn" {
  description = "Full ARN of the repository"
  value       = module.ecr.repository_arn
}

output "repository_registry_id" {
  description = "The registry ID where the repository was created"
  value       = module.ecr.repository_registry_id
}

output "repository_url" {
  description = "The URL of the repository"
  value       = module.ecr.repository_url
}
