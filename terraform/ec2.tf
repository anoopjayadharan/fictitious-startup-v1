# Imports private-ami
data "aws_ami" "custom_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["devopsify-engineering-${var.custom_ami_version}"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Retrieves vpc and subnet ids from network workspace
data "tfe_outputs" "network" {
  organization = "ajcloudlab"
  workspace    = "network"
}

# Creates an ec2 instance using the imported AMI
# resource "aws_instance" "web_server" {
#   ami                         = data.aws_ami.custom_ami.id
#   instance_type               = "t2.micro"
#   availability_zone           = var.az
#   subnet_id                   = data.tfe_outputs.network.values.public_subnet[1]
#   associate_public_ip_address = true
#   vpc_security_group_ids      = [aws_security_group.allow_http.id]
#   iam_instance_profile        = aws_iam_instance_profile.connectEC2_profile.name

#   tags = merge(local.tags,
#     {
#       Name = var.ec2_name
#   })
# }

# Creates security group
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = data.tfe_outputs.network.values.vpc

  tags = merge(local.tags,
    {
      Name = var.sg_name
  })
}

# Creates an inbound rule to allow http
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Creates an inbound rule to allow postgres from DMS
resource "aws_vpc_security_group_ingress_rule" "allow_postgres_dms" {
  security_group_id            = aws_security_group.allow_http.id
  referenced_security_group_id = aws_security_group.sg_dms_rp_instance.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

# Creates an outboud rule to allow all traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}