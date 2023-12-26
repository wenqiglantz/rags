terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
  required_version = ">= 1.6.0"
}

provider "aws" {
  region = var.aws_region
}

#######################################
# VPC/subnets/certificate retrieved from parameter store
#######################################
data "aws_ssm_parameter" "vpc_id" {
  name = "/base/vpcId"
}

data "aws_ssm_parameter" "private_subnet_a_id" {
  name = "/base/privateSubnetA"
}

data "aws_ssm_parameter" "private_subnet_b_id" {
  name = "/base/privateSubnetB"
}

data "aws_ssm_parameter" "private_subnet_c_id" {
  name = "/base/privateSubnetC"
}

data "aws_ssm_parameter" "public_subnet_a_id" {
  name = "/base/publicSubnetA"
}

data "aws_ssm_parameter" "public_subnet_b_id" {
  name = "/base/publicSubnetB"
}

data "aws_ssm_parameter" "public_subnet_c_id" {
  name = "/base/publicSubnetC"
}

data "aws_ssm_parameter" "cert" {
  name = "/base/certificateArn"
}

module "cluster_alb" {
  source = "github.com/wenqiglantz/reusable-workflows-modules//terraform/modules/ecs/cluster_alb?ref=main"

  deploy_env     = var.deploy_env
  requester_name = var.requester_name

  create_cluster = var.create_cluster
  cluster_name   = var.cluster_name
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  public_subnets = [
    data.aws_ssm_parameter.public_subnet_a_id.value,
    data.aws_ssm_parameter.public_subnet_b_id.value,
    data.aws_ssm_parameter.public_subnet_c_id.value
  ]
  alb_name                  = "${var.service_prefix}-alb"
  target_group_name         = "${var.service_prefix}-tgt-group"
  service_port_target_group = var.service_port_target_group
  context_path              = var.context_path
  healthcheck_path          = var.healthcheck_path
  alb_https_certificate_arn = data.aws_ssm_parameter.cert.value

  deploy_repo       = var.deploy_repo
  pipeline_token    = var.pipeline_token
  github_repo_owner = var.github_repo_owner
}

module "fargate" {
  source = "github.com/wenqiglantz/reusable-workflows-modules//terraform/modules/ecs/service_taskdef?ref=main"

  deploy_env     = var.deploy_env
  requester_name = var.requester_name

  cluster_name = var.cluster_name
  vpc_id       = data.aws_ssm_parameter.vpc_id.value
  private_subnets = [
    data.aws_ssm_parameter.private_subnet_a_id.value,
    data.aws_ssm_parameter.private_subnet_b_id.value,
    data.aws_ssm_parameter.private_subnet_c_id.value
  ]
  alb_security_group_id       = module.cluster_alb.alb_security_group_id
  alb_target_group_arn        = module.cluster_alb.ecs_alb_target_group_arn
  cpu                         = var.cpu
  memory                      = var.memory
  service_name                = var.service_name
  ecr_repository_name         = var.ecr_repository_name
  service_port_target_group   = var.service_port_target_group
  log_group_retention_in_days = var.log_group_retention_in_days

  deploy_repo       = var.deploy_repo
  pipeline_token    = var.pipeline_token
  github_repo_owner = var.github_repo_owner
}
