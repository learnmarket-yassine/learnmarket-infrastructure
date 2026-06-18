# S3
output "bucket_id" {
  description = "S3 bucket ID"
  value       = aws_s3_bucket.frontend.id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.frontend.arn
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.frontend.bucket
}

output "backup_bucket_name" {
  description = "Backup S3 bucket name (production only)"
  value       = var.environment == "production" ? aws_s3_bucket.frontend_backup[0].bucket : null
}

output "backup_bucket_arn" {
  description = "Backup S3 bucket ARN (production only)"
  value       = var.environment == "production" ? aws_s3_bucket.frontend_backup[0].arn : null
}

# CloudFront
output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.frontend.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.frontend.arn
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

# URL pratique
output "website_url" {
  description = "Frontend URL"
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}