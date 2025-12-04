data "aws_iam_role" "labrole" {
  name = "LabRole"
}

resource "aws_lambda_function" "chatbot" {
  filename      = "../lambda/function.zip"
  function_name = "chatbot"
  role          = data.aws_iam_role.labrole.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  source_code_hash = filebase64sha256("../lambda/function.zip")

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.chatbot-table.name
    }
  }
}