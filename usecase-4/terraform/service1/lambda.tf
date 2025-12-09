data "aws_iam_role" "labrole" {
  name = "LabRole"
}

resource "aws_lambda_function" "microservice1_serverless" {
  filename         = "../../lambda/service1/service1.zip"
  function_name    = "microservice1_serverless"
  role             = data.aws_iam_role.labrole.arn
  handler          = "app.lambda_handler"
  source_code_hash = filebase64sha256("../../lambda/service1/service1.zip")

  runtime = "python3.11"

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.microservice1-serverless.name
    }
  }
}