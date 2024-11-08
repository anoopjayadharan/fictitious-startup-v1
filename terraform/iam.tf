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

