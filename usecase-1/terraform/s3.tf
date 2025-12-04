terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "serverless" {
  bucket = "destia-serverless-project"

  tags = {
    Name        = "destia-serverless-project"
  }
}