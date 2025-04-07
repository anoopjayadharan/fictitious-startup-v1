variable "region" {}
variable "environment" {
  description = "Name of the environment."
  type        = string
}
variable "project_name" {
  description = "Name of the project."
  type        = string
}
variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {}
}
variable "custom_ami_version" {}
variable "ec2_name" {
  default = "webserver-prd"
}
variable "sg_name" {}
variable "az" {}
variable "policy_arn" {}
variable "db_username" {}
variable "db_password" {}
variable "secret_key" {}
variable "sg_postgres" {}
variable "replication_task_id" {}
variable "s3_name" {}
variable "CloudWatchAgentServerPolicy_arn" {}