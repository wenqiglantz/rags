aws_region     = "us-east-1"
requester_name = "Wenqi Glantz"

create_vpc           = true
vpc_cidr             = "172.30.0.0/16"
public_subnets_cidr  = "[172.30.144.0/24,172.30.145.0/24,172.30.146.0/24]"
private_subnets_cidr = "[172.30.147.0/24,172.30.148.0/24,172.30.149.0/24]"

create_cluster              = true
cluster_name                = "rags"
cpu                         = 512
memory                      = 1024
service_prefix              = "rags"
service_name                = "rags"
service_port_target_group   = 8501
context_path                = "/"
healthcheck_path            = "/healthz"
log_group_retention_in_days = 7
ecr_repository_name         = "rag"
