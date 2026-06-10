variable "project_name" {
  type        = string
  description = "Project name (used for resource naming)"
  default     = "learnmarket"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, production)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  default     = {}
}