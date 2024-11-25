# Terraform block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.73.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
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