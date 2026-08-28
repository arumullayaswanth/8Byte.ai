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
    key     = "staging/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

module "stack" {
  source                 = "../../modules/stack"
  name                   = var.environment
  region                 = var.region
  ecr_repo_name          = var.ecr_repo_name
  vpc_cidr               = var.vpc_cidr
  container_image        = var.container_image
  container_port         = var.container_port
  desired_count          = var.desired_count
  db_multi_az            = var.db_multi_az
  db_deletion_protection = var.db_deletion_protection
  db_skip_final_snapshot = var.db_skip_final_snapshot
  alert_email            = var.alert_email
}
