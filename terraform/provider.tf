# Terraform block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.73.0"
    }
  }
}

# Backend Terraform Cloud
terraform {
  cloud {

    organization = "ajcloudlab"

    workspaces {
      name = "development"
    }
  }
}