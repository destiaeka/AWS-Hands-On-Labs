resource "aws_api_gateway_rest_api" "chatbot" {
  name = "chatbot"
}

resource "aws_api_gateway_resource" "chatbot" {
  parent_id   = aws_api_gateway_rest_api.chatbot.root_resource_id
  path_part   = "chatbot"
  rest_api_id = aws_api_gateway_rest_api.chatbot.id
}

resource "aws_api_gateway_method" "post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.chatbot.id
  rest_api_id   = aws_api_gateway_rest_api.chatbot.id
}

resource "aws_api_gateway_integration" "post_integration" {
  http_method = aws_api_gateway_method.post.http_method
  resource_id = aws_api_gateway_resource.chatbot.id
  rest_api_id = aws_api_gateway_rest_api.chatbot.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.chatbot.arn}/invocations"
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.chatbot.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.chatbot.id
  rest_api_id   = aws_api_gateway_rest_api.chatbot.id
}

resource "aws_api_gateway_integration" "get_integration" {
  http_method = aws_api_gateway_method.get.http_method
  resource_id = aws_api_gateway_resource.chatbot.id
  rest_api_id = aws_api_gateway_rest_api.chatbot.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.chatbot.arn}/invocations"
}

resource "aws_lambda_permission" "allow_chatbot" {
  statement_id  = "AllowAPIGatewayInvokeGET"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.chatbot.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "chatbot" {
  rest_api_id = aws_api_gateway_rest_api.chatbot.id

  depends_on = [ aws_api_gateway_integration.post_integration, aws_api_gateway_integration.get_integration ]

  triggers = {
    redeploy = sha1(jsonencode(aws_api_gateway_rest_api.chatbot))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "chatbot" {
  deployment_id = aws_api_gateway_deployment.chatbot.id
  rest_api_id   = aws_api_gateway_rest_api.chatbot.id
  stage_name    = "chatbot"
}