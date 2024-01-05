aws_region     = "us-east-1"
requester_name = "Wenqi Glantz"

vpc_name            = "rags"
vpc_cidr            = "172.30.0.0/16"
cluster_name        = "rags"
task_cpu            = 2048
task_memory         = 4096
container_cpu       = 512
container_memory    = 1024
service_prefix      = "rags"
service_name        = "rags"
service_port        = 8501
healthcheck_path    = "/healthz"
ecr_repository_name = "rags"
