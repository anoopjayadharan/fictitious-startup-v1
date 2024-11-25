# Creates a random id
resource "random_id" "object" {
  byte_length = 4
}

#Creates S3 bucket
resource "aws_s3_bucket" "image-store" {
  bucket        = var.s3_name
  force_destroy = true
}

# Creates s3 bucket policy to enable OAC
resource "aws_s3_bucket_policy" "CF_S3_Policy" {
  bucket = aws_s3_bucket.image-store.id
  policy = <<EOT
  {
        "Version": "2008-10-17",
        "Id": "PolicyForCloudFrontPrivateContent",
        "Statement": [
            {
                "Sid": "AllowCloudFrontServicePrincipal",
                "Effect": "Allow",
                "Principal": {
                    "Service": "cloudfront.amazonaws.com"
                },
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::${aws_s3_bucket.image-store.id}/*",
                "Condition": {
                    "StringEquals": {
                      "AWS:SourceArn": "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.cf_distribution.id}"
                    }
                }
            }
        ]
      }
      EOT
}