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

resource "aws_dynamodb_table" "serverless_savedb_v2" {
  name           = "savedb_v2"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "chat_id"
  range_key      = "timestamp"

  attribute {
    name = "chat_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags = {
    Name        = "serverless_sns"
  }
}