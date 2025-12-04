resource "aws_dynamodb_table" "chatbot-table" {
  name           = "chatbot"
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
    attribute_name = "ttl"
    enabled = true
  }

  tags = {
    Name        = "chatbot"
  }
}