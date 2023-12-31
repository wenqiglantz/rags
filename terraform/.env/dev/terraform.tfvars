aws_region     = "us-east-1"
requester_name = "Wenqi Glantz"

vpc_cidr = "172.30.0.0/16"
cluster_name        = "rags"
cpu                 = 512
memory              = 1024
service_prefix      = "rags"
service_name        = "rags"
service_port        = 8501
healthcheck_path    = "/healthz"
ecr_repository_name = "rag"
