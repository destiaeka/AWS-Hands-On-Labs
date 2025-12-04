resource "aws_api_gateway_rest_api" "serverless" {
  name = "serverless"
}

resource "aws_api_gateway_resource" "serverless" {
  parent_id   = aws_api_gateway_rest_api.serverless.root_resource_id
  path_part   = "serverless"
  rest_api_id = aws_api_gateway_rest_api.serverless.id
}

resource "aws_api_gateway_method" "post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.serverless.id
  rest_api_id   = aws_api_gateway_rest_api.serverless.id
}

resource "aws_api_gateway_integration" "post_integration" {
  http_method = aws_api_gateway_method.post.http_method
  resource_id = aws_api_gateway_resource.serverless.id
  rest_api_id = aws_api_gateway_rest_api.serverless.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.serverless_lambda.arn}/invocations"
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.serverless_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.serverless.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.serverless.id
  rest_api_id   = aws_api_gateway_rest_api.serverless.id
}

resource "aws_api_gateway_integration" "get_integration" {
  http_method = aws_api_gateway_method.get.http_method
  resource_id = aws_api_gateway_resource.serverless.id
  rest_api_id = aws_api_gateway_rest_api.serverless.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.serverless_lambda.arn}/invocations"
}

resource "aws_lambda_permission" "allow_get" {
  statement_id  = "AllowAPIGatewayInvokeGET"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.serverless_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.serverless.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "serverless" {
  rest_api_id = aws_api_gateway_rest_api.serverless.id

  depends_on = [ aws_api_gateway_integration.post_integration, aws_api_gateway_method.get ]

  triggers = {
    redeploy = sha1(jsonencode(aws_api_gateway_rest_api.serverless))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "serverless" {
  deployment_id = aws_api_gateway_deployment.serverless.id
  rest_api_id   = aws_api_gateway_rest_api.serverless.id
  stage_name    = "serverless"
}