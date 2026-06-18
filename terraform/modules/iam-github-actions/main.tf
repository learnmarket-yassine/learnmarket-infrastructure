# ============================================
# IAM USER POUR GITHUB ACTIONS
# ============================================
resource "aws_iam_user" "github_actions" {
  name = "${var.project_name}-${var.environment}-github-actions"
  path = "/github-actions/"

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-github-actions"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Purpose     = "CI/CD deployment"
  })
}

# ============================================
# IAM POLICY
# ============================================
data "aws_iam_policy_document" "github_actions" {
  # S3 frontend bucket
  statement {
    sid    = "S3FrontendBucketAccess"
    effect = "Allow"
    
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*",
    ]
  }
  
  # Backup bucket (production)
  dynamic "statement" {
    for_each = var.backup_bucket_arn != "" ? [1] : []
    content {
      sid    = "S3BackupBucketAccess"
      effect = "Allow"
      
      actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
      ]
      
      resources = [
        var.backup_bucket_arn,
        "${var.backup_bucket_arn}/*",
      ]
    }
  }
  
  # CloudFront invalidation
  statement {
    sid    = "CloudFrontInvalidation"
    effect = "Allow"
    
    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation",
      "cloudfront:ListInvalidations",
    ]
    
    resources = [
      var.cloudfront_distribution_arn,
    ]
  }
  
  # CloudFront read
  statement {
    sid    = "CloudFrontGetDistribution"
    effect = "Allow"
    
    actions = [
      "cloudfront:GetDistribution",
      "cloudfront:GetDistributionConfig",
    ]
    
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_actions" {
  name        = "${var.project_name}-${var.environment}-github-actions"
  description = "Policy for GitHub Actions to deploy frontend"
  policy      = data.aws_iam_policy_document.github_actions.json

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  })
}

resource "aws_iam_user_policy_attachment" "github_actions" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

# ============================================
# ACCESS KEY
# ============================================
resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}