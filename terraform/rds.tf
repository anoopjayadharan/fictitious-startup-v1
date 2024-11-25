# Creates a Subnet Group for RDS instance
resource "aws_db_subnet_group" "subnet_group" {
  name       = "mvp-devops"
  subnet_ids = data.tfe_outputs.network.values.private_subnet[*]

  tags = {
    Name = "devopsifyengineering"
  }
}

# Creates a Parameter Group Name
resource "aws_db_parameter_group" "p_group" {
  name   = "mvp-devops"
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}

# Creates a RDS DB instance
resource "aws_db_instance" "rds_psql" {
  allocated_storage      = 10
  db_name                = "mvp"
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = aws_db_parameter_group.p_group.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.allow_postgres.id]
}

# Creates security group for RDS DB instance
resource "aws_security_group" "allow_postgres" {
  name        = "allow_postgres"
  description = "Allow postgress inbound traffic from webserver"
  vpc_id      = data.tfe_outputs.network.values.vpc

  tags = merge(local.tags,
    {
      Name = var.sg_postgres
  })
}

# Creates an inbound rule to allow ec2 connect postgres
resource "aws_vpc_security_group_ingress_rule" "allow_postgres_ec2" {
  security_group_id            = aws_security_group.allow_postgres.id
  referenced_security_group_id = aws_security_group.allow_http.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

# Creates an inbound rule to allow postgres from DMS
resource "aws_vpc_security_group_ingress_rule" "allow_postgres_dms_rds" {
  security_group_id            = aws_security_group.allow_postgres.id
  referenced_security_group_id = aws_security_group.sg_dms_rp_instance.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}
