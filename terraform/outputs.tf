output "ecs_cluster" {
  value = module.ecs.cluster_name
}

output "services" {
  value = module.ecs.services
}
