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