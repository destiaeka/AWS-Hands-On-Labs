terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "ecommerce" {
  bucket = "destia-serverless-ecommerce"

  tags = {
    Name        = "destia-serverless-ecommerce"
  }
}