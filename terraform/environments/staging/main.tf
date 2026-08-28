terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # bucket and lock table are passed at init time (see backend.hcl). both are
  # created manually before the pipeline ever runs.
  backend "s3" {
    key     = "staging/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = "8byte-devops-assignment"
      Environment = "staging"
      ManagedBy   = "terraform"
    }
  }
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "container_image" {
  type = string
}

variable "alert_email" {
  type    = string
  default = ""
}

module "stack" {
  source          = "../../modules/stack"
  name            = "staging"
  region          = var.region
  vpc_cidr        = "10.0.0.0/16"
  container_image = var.container_image
  desired_count   = 1
  db_multi_az     = false
  alert_email     = var.alert_email
}

output "alb_dns_name" { value = module.stack.alb_dns_name }
output "ecr_repository_url" { value = module.stack.ecr_repository_url }
output "ecs_cluster_name" { value = module.stack.ecs_cluster_name }
output "ecs_service_name" { value = module.stack.ecs_service_name }
output "db_endpoint" { value = module.stack.db_endpoint }
output "app_dashboard" { value = module.stack.app_dashboard }
output "db_dashboard" { value = module.stack.db_dashboard }
