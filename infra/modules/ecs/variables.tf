variable "region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}
variable "flask_image_uri" {
  description = "ECR URI for Flask app image"
  type        = string
}

variable "task_execution_role_arn" {
  description = "ARN of ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of ECS task role"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}
variable "app_name" {}
variable "alb_security_group_id" {}
variable "ecr_repository_url" {}
variable "task_execution_role_arn" {}