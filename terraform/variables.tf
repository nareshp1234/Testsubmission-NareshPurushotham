##############################
# General Project Settings
##############################
variable "aws_region" {
  description = "AWS region where all resources will be deployed"
  type        = string
  default     = "us-east-1"
}



variable "project" {
  description = "Project name prefix for all AWS resources"
  type        = string
  default     = "banking-app"
}

variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "List of availability zones to deploy subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

##############################
# Networking
##############################

variable "public_subnets" {
  description = "List of public subnet IDs (if creating new subnets)"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet IDs ( if creating new subnets)"
  type        = list(string)
  default     = []
}

##############################
# ECS / Application Settings
##############################

variable "desired_count" {
  description = "Number of ECS tasks to run for the application service"
  type        = number
  default     = 2
}

variable "image_tag" {
  description = "Docker image tag to deploy from ECR"
  type        = string
  default     = "latest"
}

variable "ecr_repo" {
  description = "ECR repository name for the app image"
  type        = string
  default     = "banking-app-repo"
}

##############################
# ALB (Load Balancer)
##############################

variable "enable_alb_access_logs" {
  description = "Enable or disable ALB access logs"
  type        = bool
  default     = false
}

variable "alb_logs_bucket" {
  description = "S3 bucket name for ALB access logs"
  type        = string
  default     = ""
}

variable "acm_cert_arn" {
  description = "ACM certificate ARN for HTTPS listener on ALB"
  type        = string
  default     = ""
}

##############################
# RDS (Database)
##############################

variable "db_username" {
  description = "Username for RDS PostgreSQL instance"
  type        = string
  default     = "postgres123"
}

variable "db_password" {
  description = "Password for RDS PostgreSQL instance"
  type        = string
  sensitive   = true
  default     = "postgres123"
}

##############################
# Tags
##############################

locals {
  common_tags = {
    Project   = var.project
    ManagedBy = "Terraform"
    Env       = "dev"
  }
}
