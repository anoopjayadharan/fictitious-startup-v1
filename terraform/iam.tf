# Creates iam role
resource "aws_iam_role" "ec2_ssm" {
  name = "ConnectEC2"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}
# Attaches 'AmazonSSMManagedInstanceCore' policy to the 'ConnectEC2' role
resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = var.policy_arn
}
# Creates iam instance profile
resource "aws_iam_instance_profile" "connectEC2_profile" {
  name = "ConnectEC2"
  role = aws_iam_role.ec2_ssm.name
}

# IAM policy for Webserver to list/read/write/delete images on S3
resource "aws_iam_policy" "ec2_s3_policy" {
  name        = "ec2_image_store_s3_policy"
  description = "Allow webserver to read,write,list and update images"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : "arn:aws:s3:::${aws_s3_bucket.image-store.id}*"
      }
    ]
  })
}

# Attach policy to the EC2 Instance profile
resource "aws_iam_role_policy_attachment" "policy-attach-s3" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = aws_iam_policy.ec2_s3_policy.arn
}

# IAM policy for Webserver to read parameter store
resource "aws_iam_policy" "ec2_ssm_parameter_policy" {
  name        = "ec2_ssm_parameter_policy"
  description = "Allow webserver to read parameter store"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:DescribeParameters",
          "ssm:GetParameters"
        ],
        "Resource" : "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/cloudtalents/startup/*"
      }
    ]
  })
}

# Attach policy to the EC2 Instance profile
resource "aws_iam_role_policy_attachment" "policy-attach-ssm-parameter" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = aws_iam_policy.ec2_ssm_parameter_policy.arn
}




