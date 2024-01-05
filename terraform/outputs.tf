output "ecs_cluster" {
  value = module.ecs.cluster_name
}

output "repository_url" {
  description = "The URL of the repository"
  value       = module.ecr.repository_url
}

output "alb_dns" {
  description = "The DNS name of ALB"
  value       = module.alb.dns_name
}
