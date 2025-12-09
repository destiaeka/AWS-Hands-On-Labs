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

resource "aws_dynamodb_table" "service2-serverless" {
  name           = "service2"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "book_id"

  attribute {
    name = "book_id"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = {
    Name        = "service2"
  }
}