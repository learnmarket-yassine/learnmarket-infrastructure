output "endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "Database endpoint (host:port)"
}

output "address" {
  value       = aws_db_instance.main.address
  description = "Database hostname"
}

output "port" {
  value       = aws_db_instance.main.port
  description = "Database port"
}

output "db_name" {
  value       = aws_db_instance.main.db_name
  description = "Database name"
}

output "username" {
  value       = aws_db_instance.main.username
  description = "Database username"
}

output "password_secret_arn" {
  value       = aws_secretsmanager_secret.db_password.arn
  description = "ARN of the Secrets Manager secret containing the password"
  sensitive   = true
}

output "security_group_id" {
  value = aws_security_group.rds.id
}