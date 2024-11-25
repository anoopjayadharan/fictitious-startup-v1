# Creates SSM parameter store for
#  * db username
#  * db password
#  * db secret_key
#  * rds endpoint
#  * s3 bucket name
#  * cloudfront domain
resource "aws_ssm_parameter" "db_username" {
  name  = "/cloudtalents/startup/db_user"
  type  = "String"
  value = var.db_username
}
resource "aws_ssm_parameter" "db_password" {
  name  = "/cloudtalents/startup/db_password"
  type  = "String"
  value = var.db_password
}
resource "aws_ssm_parameter" "db_secret_key" {
  name  = "/cloudtalents/startup/secret_key"
  type  = "String"
  value = var.secret_key
}
resource "aws_ssm_parameter" "rds_endpoint" {
  name  = "/cloudtalents/startup/database_endpoint"
  type  = "String"
  value = aws_db_instance.rds_psql.address
}
resource "aws_ssm_parameter" "s3_bucket_name" {
  name  = "/cloudtalents/startup/image_storage_bucket_name"
  type  = "String"
  value = aws_s3_bucket.image-store.id
}
resource "aws_ssm_parameter" "cf_domain_name" {
  name  = "/cloudtalents/startup/image_storage_cloudfront_domain"
  type  = "String"
  value = aws_cloudfront_distribution.cf_distribution.domain_name
}