aws_region     = "us-east-1"
requester_name = "Wenqi Glantz"

create_cluster              = true
cluster_name                = "rag"
cpu                         = 512
memory                      = 1024
service_prefix              = "rag"
service_name                = "rag"
service_port_target_group   = 8501
context_path                = "rag"
healthcheck_path            = "/_stcore/health"
log_group_retention_in_days = 7
ecr_repository_name         = "rag"
github_repo_owner           = "wenqiglantz"
