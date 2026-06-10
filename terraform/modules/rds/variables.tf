variable "project_name" {
  type    = string
  default = "learnmarket"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs (must be at least 2)"
}

variable "ec2_security_group_id" {
  type        = string
  description = "Security group ID of EC2 instances that need access"
}

variable "db_name" {
  type    = string
  default = "learnmarket"
}

variable "db_username" {
  type    = string
  default = "learnmarket_admin"
}

variable "postgres_version" {
  type    = string
  default = "16"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"  # Free tier
}

variable "allocated_storage" {
  type        = number
  description = "Storage in GB"
  default     = 20  # Free tier max
}

variable "backup_retention_period" {
  type        = number
  description = "Days to retain backups"
  default     = 1
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot on destroy (true for dev, false for prod)"
  default     = true
}

variable "deletion_protection" {
  type        = bool
  description = "Prevent accidental deletion"
  default     = false
}

variable "common_tags" {
  type    = map(string)
  default = {}
}