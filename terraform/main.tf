provider "aws" {
  region = var.region
}
provider "random" {}
locals {
  s3_origin_id   = "${var.s3_name}-origin"
  s3_domain_name = aws_s3_bucket.image-store.bucket_regional_domain_name
  required_tags = {
    project     = var.project_name
    environment = var.environment
  }
  tags = merge(var.resource_tags, local.required_tags)
}

# Imports current account id
data "aws_caller_identity" "current" {}