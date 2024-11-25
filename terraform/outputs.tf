output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}
output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.rds_psql.address
  sensitive   = true
}
