 provider "aws" {
    region = var.region
    shared_credentials_files = [ var.shared_credentials_file ]
    profile = "default"
  }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}