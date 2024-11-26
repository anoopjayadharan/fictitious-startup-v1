# Database Migration Service requires the below IAM Roles to be created before
# replication instances can be created.
#  * dms-vpc-role

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "dms-vpc-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-vpc-role"
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}

# Creates DMS replication subnet group. It requires "dms-vpc-role"
resource "aws_dms_replication_subnet_group" "rp_subnet_grp" {
  replication_subnet_group_description = "Replication subnet group"
  replication_subnet_group_id          = "mvp-devops"

  subnet_ids = data.tfe_outputs.network.values.private_subnet[*]

  tags = {
    Name = "mvp-devops"
  }

  # explicit depends_on is needed since this resource doesn't reference the role or policy attachment
  depends_on = [aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole]
}

# Creates a new replication instance
resource "aws_dms_replication_instance" "dms_replication_instance" {
  count                       = 0           # prevent dms replication instance creation as migration is complete
  allocated_storage           = 10
  apply_immediately           = true
  multi_az                    = false
  replication_instance_class  = "dms.t2.micro"
  replication_instance_id     = "mvp-deops-dms"
  replication_subnet_group_id = aws_dms_replication_subnet_group.rp_subnet_grp.id

  tags = {
    Name = "mvp-deops"
  }

  vpc_security_group_ids = [aws_security_group.sg_dms_rp_instance.id]

  depends_on = [aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole]
}

# Creates security group for DMS Replication instance
resource "aws_security_group" "sg_dms_rp_instance" {
  name        = "dms-security-group"
  description = "security group for DMS replication instance"
  vpc_id      = data.tfe_outputs.network.values.vpc
}

# Creates an outboud rule to allow all traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.sg_dms_rp_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Creates a source endpoint - webserver
resource "aws_dms_endpoint" "ec2" {
  database_name = "mvp"
  endpoint_id   = "webserver"
  endpoint_type = "source"
  engine_name   = "postgres"
  password      = var.db_password
  port          = 5432
  server_name   = aws_instance.web_server.private_ip
  ssl_mode      = "none"

  tags = {
    Name = "mvp-devops"
  }

  username = var.db_username
}
# Creates a target endpoint - RDS
resource "aws_dms_endpoint" "rds" {
  database_name = "mvp"
  endpoint_id   = "rds"
  endpoint_type = "target"
  engine_name   = "postgres"
  password      = var.db_password
  port          = 5432
  server_name   = aws_db_instance.rds_psql.address
  ssl_mode      = "none"

  tags = {
    Name = "mvp-devops"
  }

  username = var.db_username
}

# Create a new DMS replication task
resource "aws_dms_replication_task" "dblink" {
  count          = 0                  # prevent dms replication task creation as migration is complete
  migration_type = "full-load"

  #replication_instance_arn = "${aws_dms_replication_instance.link.replication_instance_arn}"
  replication_instance_arn = aws_dms_replication_instance.dms_replication_instance[count.index].replication_instance_arn
  replication_task_id      = var.replication_task_id
  source_endpoint_arn      = aws_dms_endpoint.ec2.endpoint_arn
  table_mappings           = file("table-mappings.json")
  target_endpoint_arn      = aws_dms_endpoint.rds.endpoint_arn

  tags = {
    Name = "mvp-devops"
  }
}
