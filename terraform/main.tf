terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
    github = {
      source  = "integrations/github"
      version = "5.42.0"
    }
  }
  required_version = ">= 1.6.0"
}

provider "aws" {
  region = var.aws_region
  # default tags per https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags-configuration-block
  default_tags {
    tags = {
      requester = var.requester_name
      env       = var.deploy_env
      ManagedBy = "Terraform"
    }
  }
}

# for github secrets creation
provider "github" {
  token = var.pipeline_token
  owner = var.github_repo_owner
}

################################################################################
# Supporting Resources
################################################################################
data "aws_ssm_parameter" "cert" {
  name = "/base/certificateArn"
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  name = var.vpc_name

  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

resource "aws_service_discovery_http_namespace" "this" {
  name        = local.name
  description = "CloudMap namespace for ${local.name}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket_prefix = "${local.name}-logs-"
  acl           = "log-delivery-write"

  # For example only
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_elb_log_delivery_policy = true # Required for ALB logs
  attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.4.0"

  name    = "${var.service_prefix}-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = var.service_port
      to_port     = var.service_port
      ip_protocol = "tcp"
      description = "ingress for HTTP traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "ingress for HTTPS traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  access_logs = {
    bucket = module.log_bucket.s3_bucket_id
    prefix = "access-logs"
  }

  listeners = {
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = data.aws_ssm_parameter.cert.value

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix = var.service_name
      protocol    = "HTTP"
      port        = var.service_port
      target_type = "ip"

      health_check = {
        enabled             = true
        interval            = 30
        path                = var.healthcheck_path
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 5
        timeout             = 10
        protocol            = "HTTP"
        matcher             = "200-399"
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }

  tags = {
    Environment = var.deploy_env
    Project     = var.service_name
  }
}


module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.7.4"

  cluster_name = var.cluster_name

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/${var.cluster_name}"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  services = {
    rags = {
      cpu    = var.task_cpu
      memory = var.task_memory

      # Container definition(s)
      container_definitions = {

        fluent-bit = {
          cpu       = 512
          memory    = 1024
          essential = true
          image = "amazon/aws-for-fluent-bit:latest"
          firelens_configuration = {
            type = "fluentbit"
          }
          memory_reservation = 50
        }

        rags = {
          cpu       = var.container_cpu
          memory    = var.container_memory
          essential = true
          image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository_name}:latest"
          port_mappings = [
            {
              name          = var.service_name
              containerPort = var.service_port
              protocol      = "tcp"
            }
          ]

          # image requires access to write to root filesystem
          readonly_root_filesystem = false

          dependencies = [{
            containerName = "fluent-bit"
            condition     = "START"
          }]

          enable_cloudwatch_logging = false
          log_configuration = {
            logDriver = "awsfirelens"
            options = {
              Name                    = "firehose"
              region                  = var.aws_region
              delivery_stream         = "my-stream"
              log-driver-buffer-limit = "2097152"
            }
          }
          memory_reservation = 100
        }
      }

      service_connect_configuration = {
        namespace = aws_service_discovery_http_namespace.this.arn
        service = {
          client_alias = {
            port     = var.service_port
            dns_name = var.service_name
          }
          port_name      = var.service_name
          discovery_name = var.service_name
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["ex-instance"].arn
          container_name   = var.service_name
          container_port   = var.service_port
        }
      }

      subnet_ids = module.vpc.private_subnets
      security_group_rules = {
        alb_ingress_3000 = {
          type                     = "ingress"
          from_port                = var.service_port
          to_port                  = var.service_port
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = module.alb.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  tags = {
    Environment = var.deploy_env
    Project     = var.service_name
  }
}

module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "rags"

  repository_read_write_access_arns = [
    module.ecs.services["rags"].task_exec_iam_role_arn,
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/github-actions-role"
  ]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 3 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 3
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_force_delete = true

}

#######################################
# GitHub env variable creation, need these variables for app CI/CD in github actions
#######################################
resource "github_actions_environment_variable" "ecs_cluster" {
  repository    = var.deploy_repo
  environment   = var.deploy_env
  variable_name = "ECS_CLUSTER"
  value         = module.ecs.cluster_name
}

resource "github_actions_environment_variable" "ecs_task_definition" {
  repository    = var.deploy_repo
  environment   = var.deploy_env
  variable_name = "ECS_TASK_DEFINITION"
  value         = var.service_name
}

resource "github_actions_environment_variable" "container_name" {
  repository    = var.deploy_repo
  environment   = var.deploy_env
  variable_name = "CONTAINER_NAME"
  value         = var.service_name
}

resource "github_actions_environment_variable" "ecs_service" {
  repository    = var.deploy_repo
  environment   = var.deploy_env
  variable_name = "ECS_SERVICE"
  value         = var.service_name
}

resource "github_actions_environment_variable" "ecr_repository_name" {
  repository    = var.deploy_repo
  environment   = var.deploy_env
  variable_name = "ECR_REPOSITORY_NAME"
  value         = var.ecr_repository_name
}
