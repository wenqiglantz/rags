aws_region     = "us-east-1"
requester_name = "Wenqi Glantz"

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
