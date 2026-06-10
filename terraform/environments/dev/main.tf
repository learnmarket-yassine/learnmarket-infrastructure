# ==========================================
# Configuration Terraform
# ==========================================
terraform {
  required_version = ">= 1.6.0"
  
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
  
  # Backend S3 pour stocker le state
  # IMPORTANT : remplace BUCKET_NAME par celui généré par bootstrap.sh
  backend "s3" {
    bucket         = "learnmarket-terraform-state-1781102476"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-3"
    encrypt        = true
    dynamodb_table = "learnmarket-terraform-locks"
  }
}

# ==========================================
# Provider AWS
# ==========================================
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "learnmarket"
      Environment = "dev"
      ManagedBy   = "terraform"
      Owner       = "amine"
    }
  }
}

# ==========================================
# Locals (variables locales calculées)
# ==========================================
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ==========================================
# Module : Réseau (VPC)
# ==========================================
module "network" {
  source = "../../modules/network"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  common_tags  = local.common_tags
}

# ==========================================
# Module : EC2 Backend
# ==========================================
module "ec2" {
  source = "../../modules/ec2"
  
  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.network.vpc_id
  public_subnet_id    = module.network.public_subnet_ids[0]
  ssh_public_key_path = var.ssh_public_key_path
  admin_ip_cidr       = var.admin_ip_cidr
  instance_type       = var.ec2_instance_type
  common_tags         = local.common_tags
}

# ==========================================
# Module : RDS PostgreSQL
# ==========================================
module "rds" {
  source = "../../modules/rds"
  
  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  ec2_security_group_id = module.ec2.security_group_id
  
  # Config DB
  db_name           = "learnmarket"
  db_username       = "learnmarket_admin"
  instance_class    = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage
  
  # Dev settings : on accepte la perte de données
  skip_final_snapshot = true
  deletion_protection = false
  
  common_tags = local.common_tags
}