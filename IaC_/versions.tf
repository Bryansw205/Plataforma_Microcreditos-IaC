terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "microcreditos-terraform-state-bryan-2024"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}