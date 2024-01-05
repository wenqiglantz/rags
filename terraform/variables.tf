variable "deploy_repo" {
  description = "application's repo name"
  type        = string
}

variable "deploy_env" {
  description = "deployment environment"
  type        = string
  default     = "dev"
}

variable "pipeline_token" {
  description = "CI injected variable, pipeline token"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "The name of the vpc"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
  type        = string
}

variable "requester_name" {
  description = "requestor name tag"
  type        = string
}

variable "github_repo_owner" {
  description = "GitHub repo owner"
  type        = string
  default     = ""
}

/* variable "create_cluster" {
  description = "flag to create new cluster or use existing one"
  type        = bool
  default     = true
} */

variable "cluster_name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

variable "service_prefix" {
  type        = string
  description = "service prefix to be used in naming resources such as ALB, target group, security group, etc."
}

variable "container_cpu" {
  description = "The container CPU size"
  type        = string
  default     = "512"
}

variable "container_memory" {
  description = "The container memory size"
  type        = string
  default     = "1024"
}

variable "task_cpu" {
  description = "The task CPU size"
  type        = string
  default     = "512"
}

variable "task_memory" {
  description = "The task memory size"
  type        = string
  default     = "1024"
}

variable "service_name" {
  type        = string
  description = "service name, the same as the ECR image name"
}

variable "ecr_repository_name" {
  type        = string
  default     = "default"
  description = "The ECR repository name"
}

variable "service_port" {
  description = "application's service port"
  type        = number
  default     = 8501
}

/* variable "context_path" {
  description = "application's path, used for ALB listener rule configuration"
  type        = string
  default     = ""
} */

variable "healthcheck_path" {
  description = "application's health check path"
  type        = string
  default     = ""
}

/* variable "log_group_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, etc."
  type        = number
  default     = 7
}

variable "alb_request_count_per_target" {
  description = "ALB request count per target, used for target_tracking_scaling_policy_configuration"
  type        = string
}

variable "ecs_autoscaling_target_max_capacity" {
  description = "ecs autoscaling target max_capacity"
  type        = number
  default     = 5
}

variable "ecs_autoscaling_target_min_capacity" {
  description = "ecs autoscaling target min_capacity"
  type        = number
  default     = 1
} */
