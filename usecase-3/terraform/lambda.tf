data "aws_iam_role" "labrole" {
  name = "LabRole"
}

resource "aws_lambda_function" "product" {
  filename         = "../lambda/product/product.zip"
  function_name    = "product_handler"
  role             = data.aws_iam_role.labrole.arn
  handler          = "main.lambda_handler"
  source_code_hash = filebase64sha256("../lambda/product/product.zip")
  runtime = "python3.11"

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.products.name
    }
  }
}

resource "aws_lambda_function" "order" {
  filename         = "../lambda/order/order.zip"
  function_name    = "order_handler"
  role             = data.aws_iam_role.labrole.arn
  handler          = "main.lambda_handler"
  source_code_hash = filebase64sha256("../lambda/order/order.zip")
  runtime = "python3.11"

  environment {
    variables = {
      ORDER_TABLE = aws_dynamodb_table.orders.name
    }
  }
}

resource "aws_lambda_function" "image" {
  filename         = "../lambda/image/image.zip"
  function_name    = "image_handler"
  role             = data.aws_iam_role.labrole.arn
  handler          = "main.lambda_handler"
  source_code_hash = filebase64sha256("../lambda/image/image.zip")
  runtime = "python3.11"

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.ecommerce.bucket
    }
  }
}