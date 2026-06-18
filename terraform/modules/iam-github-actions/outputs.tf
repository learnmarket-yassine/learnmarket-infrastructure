output "iam_user_name" {
  description = "IAM user name"
  value       = aws_iam_user.github_actions.name
}

output "access_key_id" {
  description = "AWS access key ID for GitHub Actions"
  value       = aws_iam_access_key.github_actions.id
}

output "secret_access_key" {
  description = "AWS secret access key (SENSITIVE)"
  value       = aws_iam_access_key.github_actions.secret
  sensitive   = true
}