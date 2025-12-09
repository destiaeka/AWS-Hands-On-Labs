data "aws_iam_role" "labrole" {
  name = "LabRole"
}

resource "aws_lambda_function" "microservice2_serverless" {
  filename         = "../../lambda/service2/service2.zip"
  function_name    = "microservice2_serverless"
  role             = data.aws_iam_role.labrole.arn
  handler          = "app.lambda_handler"
  source_code_hash = filebase64sha256("../../lambda/service2/service2.zip")

  runtime = "python3.11"

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.service2-serverless.name
    }
  }
}