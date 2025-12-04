data "aws_iam_role" "labrole" {
  name = "LabRole"
}

resource "aws_lambda_function" "serverless_lambda" {
  filename      = "../lambda/lambda.zip"
  function_name = "serverless_lambda"
  role          = data.aws_iam_role.labrole.arn
  handler       = "upload_handler.lambda_handler"
  runtime       = "python3.11"
  source_code_hash = filebase64sha256("../lambda/lambda.zip")

  environment {
    variables = {
      BUCKET = aws_s3_bucket.serverless.bucket
    }
  }
}