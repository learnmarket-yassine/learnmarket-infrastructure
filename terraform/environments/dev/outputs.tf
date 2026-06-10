# ==========================================
# Network outputs
# ==========================================
output "vpc_id" {
  value       = module.network.vpc_id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = module.network.public_subnet_ids
  description = "Public subnet IDs"
}

# ==========================================
# EC2 outputs
# ==========================================
output "ec2_instance_id" {
  value       = module.ec2.instance_id
  description = "EC2 instance ID"
}

output "ec2_public_ip" {
  value       = module.ec2.public_ip
  description = "EC2 public IP (Elastic IP)"
}

output "ssh_command" {
  value       = module.ec2.ssh_command
  description = "Command to SSH into the EC2"
}

# ==========================================
# RDS outputs
# ==========================================
output "rds_endpoint" {
  value       = module.rds.endpoint
  description = "RDS endpoint (host:port)"
  sensitive   = true
}

output "rds_address" {
  value       = module.rds.address
  description = "RDS hostname"
  sensitive   = true
}

output "rds_port" {
  value       = module.rds.port
  description = "RDS port"
}

output "rds_db_name" {
  value       = module.rds.db_name
  description = "Database name"
}

output "rds_username" {
  value       = module.rds.username
  description = "Database username"
}

output "rds_password_secret_arn" {
  value       = module.rds.password_secret_arn
  description = "Secrets Manager ARN containing DB password"
  sensitive   = true
}

# ==========================================
# Connection helpers
# ==========================================
output "database_url_template" {
  value       = "postgresql://${module.rds.username}:PASSWORD@${module.rds.address}:${module.rds.port}/${module.rds.db_name}?schema=public"
  description = "DATABASE_URL template (replace PASSWORD with actual value from Secrets Manager)"
  sensitive   = true
}

output "get_password_command" {
  value       = "aws secretsmanager get-secret-value --secret-id ${module.rds.password_secret_arn} --query SecretString --output text"
  description = "Command to retrieve the database password"
  sensitive   = true
}