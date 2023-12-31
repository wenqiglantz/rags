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

data "aws_ssm_parameter" "cert" {
  name = "/base/certificateArn"
}

data "aws_caller_identity" "current" {}
//data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"

  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
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

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.4.0"

  name    = "${var.service_prefix}-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

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
    bucket = "${var.service_prefix}-alb-logs"
  }

  listeners = {
    ex-http-https-redirect = {
      port     = var.service_port
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = var.service_port
      protocol        = "HTTPS"
      certificate_arn = data.aws_ssm_parameter.cert.value

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix = "h1"
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
      cpu    = var.cpu
      memory = var.memory

      # Container definition(s)
      container_definitions = {

        fluent-bit = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "906394416424.dkr.ecr.us-west-2.amazonaws.com/aws-for-fluent-bit:stable"
          firelens_configuration = {
            type = "fluentbit"
          }
          memory_reservation = 50
        }

        rags = {
          cpu       = var.cpu
          memory    = var.memory
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
        namespace = "rags"
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
      security_group_ingress_rules = {
        alb_ingress_3000 = {
          type        = "ingress"
          from_port   = var.service_port
          to_port     = var.service_port
          protocol    = "tcp"
          description = "Service port"
        }
      }
      security_group_egress_rules = {
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


# module "cluster_alb" {
#   source = "github.com/wenqiglantz/reusable-workflows-modules//terraform/modules/ecs/cluster_alb?ref=main"

#   deploy_env     = var.deploy_env
#   requester_name = var.requester_name

#   create_cluster            = var.create_cluster
#   cluster_name              = var.cluster_name
#   alb_name                  = "${var.service_prefix}-alb"
#   service_port_target_group = var.service_port_target_group
#   context_path              = var.context_path
#   alb_https_certificate_arn = data.aws_ssm_parameter.cert.value

#   deploy_repo       = var.deploy_repo
#   pipeline_token    = var.pipeline_token
#   github_repo_owner = var.github_repo_owner
# }

# module "fargate" {
#   source = "github.com/wenqiglantz/reusable-workflows-modules//terraform/modules/ecs/service_taskdef?ref=main"

#   deploy_env     = var.deploy_env
#   requester_name = var.requester_name

#   create_cluster                      = var.create_cluster
#   cluster_name                        = var.cluster_name
#   alb_security_group_id               = module.cluster_alb.alb_security_group_id
#   alb_target_group_arn                = module.cluster_alb.ecs_alb_target_group_arn
#   cpu                                 = var.cpu
#   memory                              = var.memory
#   service_name                        = var.service_name
#   ecr_repository_name                 = var.ecr_repository_name
#   service_port_target_group           = var.service_port_target_group
#   log_group_retention_in_days         = var.log_group_retention_in_days
#   healthcheck_path                    = var.healthcheck_path
#   target_group_name                   = "${var.service_prefix}-tgt-group"
#   alb_request_count_per_target        = var.alb_request_count_per_target
#   ecs_autoscaling_target_max_capacity = var.ecs_autoscaling_target_max_capacity
#   ecs_autoscaling_target_min_capacity = var.ecs_autoscaling_target_min_capacity

#   deploy_repo       = var.deploy_repo
#   pipeline_token    = var.pipeline_token
#   github_repo_owner = var.github_repo_owner
# }
