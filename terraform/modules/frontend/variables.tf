variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "environment" {
  description = "Environment (dev or production)"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100" 
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}