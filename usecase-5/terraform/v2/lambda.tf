data "aws_iam_role" "labrole" {
  name = "LabRole"
}

resource "aws_lambda_function" "massage_send" {
  filename         = "../../src/version2/sendmassage.zip"
  function_name    = "serverless_sendmassage"
  role             = data.aws_iam_role.labrole.arn
  handler          = "handler.lambda_handler"
  source_code_hash = filebase64sha256("../../src/version2/sendmassage.zip")

  runtime = "python3.11"

  environment {
    variables = {
      TELEGRAM_BOT_TOKEN = "8158494614:AAH59-f1CTN4fiYT-0878m9WxxvCTP6Fn34"
      TELEGRAM_CHAT_ID   = "8355773223"
      DYNAMODB_TABLE = aws_dynamodb_table.serverless_savedb_v2.name
    }
  }
}