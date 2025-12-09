# ===============================================================================
resource "aws_api_gateway_rest_api" "service2" {
  name = "service2"
}

# ==============================================================================
resource "aws_api_gateway_resource" "book" {
  parent_id   = aws_api_gateway_rest_api.service2.root_resource_id
  path_part   = "book"
  rest_api_id = aws_api_gateway_rest_api.service2.id
}

# ===============================================================================
resource "aws_api_gateway_method" "post_book" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.book.id
  rest_api_id   = aws_api_gateway_rest_api.service2.id
}

resource "aws_api_gateway_integration" "post_book" {
  http_method = aws_api_gateway_method.post_book.http_method
  resource_id = aws_api_gateway_resource.book.id
  rest_api_id = aws_api_gateway_rest_api.service2.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.microservice2_serverless.arn}/invocations"
}

resource "aws_lambda_permission" "allow_post_book" {
  statement_id  = "AllowAPIGatewayInvokePostBook"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.microservice2_serverless.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.service2.execution_arn}/*/*"
}

# ================================================================================
resource "aws_api_gateway_method" "get_book" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.book.id
  rest_api_id   = aws_api_gateway_rest_api.service2.id
}

resource "aws_api_gateway_integration" "get_book" {
  http_method = aws_api_gateway_method.get_book.http_method
  resource_id = aws_api_gateway_resource.book.id
  rest_api_id = aws_api_gateway_rest_api.service2.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.microservice2_serverless.arn}/invocations"
}

resource "aws_lambda_permission" "allow_get_book" {
  statement_id  = "AllowAPIGatewayInvokeGetBook"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.microservice2_serverless.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.service2.execution_arn}/*/*"
}

# =================================================================================
resource "aws_api_gateway_method" "options_book" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.book.id
  rest_api_id   = aws_api_gateway_rest_api.service2.id
}

resource "aws_api_gateway_integration" "options_book" {
  http_method = aws_api_gateway_method.options_book.http_method
  resource_id = aws_api_gateway_resource.book.id
  rest_api_id = aws_api_gateway_rest_api.service2.id
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_book" {
  rest_api_id = aws_api_gateway_rest_api.service2.id
  resource_id = aws_api_gateway_resource.book.id
  http_method = aws_api_gateway_method.options_book.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_integration_response" "options_book" {
  rest_api_id = aws_api_gateway_rest_api.service2.id
  resource_id = aws_api_gateway_resource.book.id
  http_method = aws_api_gateway_method.options_book.http_method
  status_code = aws_api_gateway_method_response.options_book.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,GET,OPTIONS'"
  }
}

# ===============================================================================
resource "aws_api_gateway_deployment" "service2_deployment" {
  rest_api_id = aws_api_gateway_rest_api.service2.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.post_book,
      aws_api_gateway_integration.get_book
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ================================================================================
resource "aws_api_gateway_stage" "service2" {
  deployment_id = aws_api_gateway_deployment.service2_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.service2.id
  stage_name    = "prod"
}