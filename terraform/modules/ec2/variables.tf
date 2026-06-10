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
  description = "VPC ID where to create resources"
}

variable "public_subnet_id" {
  type        = string
  description = "Public subnet ID for the EC2 instance"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key file"
  default     = "~/.ssh/id_ed25519_github.pub"
}

variable "admin_ip_cidr" {
  type        = string
  description = "Admin IP in CIDR format (your public IP/32)"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"  # Free tier
}

variable "common_tags" {
  type        = map(string)
  default     = {}
}