variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-3"
}

variable "project_name" {
  type        = string
  description = "Project name"
  default     = "learnmarket"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "prod"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to your SSH public key"
  default     = "~/.ssh/id_ed25519_github.pub"
}

variable "admin_ip_cidr" {
  type        = string
  description = "Your public IP in CIDR notation (find with: curl https://api.ipify.org)"
  # Pas de default : à fournir via terraform.tfvars
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"  # Free Tier
}

variable "rds_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"  # Free Tier
}

variable "rds_allocated_storage" {
  type        = number
  description = "RDS storage in GB"
  default     = 20  # Free Tier max
}