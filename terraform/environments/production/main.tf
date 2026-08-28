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

  backend "s3" {
    key     = "production/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = "8byte-devops-assignment"
      Environment = "production"
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
  name            = "production"
  region          = var.region
  vpc_cidr        = "10.1.0.0/16"
  container_image = var.container_image
  desired_count   = 2

  db_multi_az            = true
  db_deletion_protection = true
  db_skip_final_snapshot = false

  alert_email = var.alert_email
}

output "alb_dns_name" { value = module.stack.alb_dns_name }
output "ecr_repository_url" { value = module.stack.ecr_repository_url }
output "ecs_cluster_name" { value = module.stack.ecs_cluster_name }
output "ecs_service_name" { value = module.stack.ecs_service_name }
output "db_endpoint" { value = module.stack.db_endpoint }
output "app_dashboard" { value = module.stack.app_dashboard }
output "db_dashboard" { value = module.stack.db_dashboard }
