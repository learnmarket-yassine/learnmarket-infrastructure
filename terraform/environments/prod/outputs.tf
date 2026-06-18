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

# ============================================
# FRONTEND OUTPUTS (PROD)
# ============================================

output "frontend_s3_bucket" {
  description = "Frontend S3 bucket name"
  value       = module.frontend_prod.bucket_name
}

output "frontend_cloudfront_id" {
  description = "Frontend CloudFront distribution ID"
  value       = module.frontend_prod.distribution_id
}

output "frontend_url" {
  description = "Frontend URL (CloudFront)"
  value       = module.frontend_prod.website_url
}

# ============================================
# GITHUB ACTIONS CREDENTIALS (PROD)
# ============================================

output "github_actions_access_key_id" {
  description = "AWS access key ID for GitHub Actions (PROD)"
  value       = module.iam_github_actions_prod.access_key_id
}

output "github_actions_secret_key" {
  description = "AWS secret key for GitHub Actions (PROD) - SENSITIVE"
  value       = module.iam_github_actions_prod.secret_access_key
  sensitive   = true
}