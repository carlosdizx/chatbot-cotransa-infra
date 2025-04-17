terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.82.0"
    }
  }
  required_version = "~>1.11.0"
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
  default_tags {
    tags = var.tags
  }
}