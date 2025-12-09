# =====================================================================================
resource "aws_api_gateway_rest_api" "service1" {
  name = "service1"
}

# =====================================================================================
resource "aws_api_gateway_resource" "product" {
  parent_id   = aws_api_gateway_rest_api.service1.root_resource_id
  path_part   = "product"
  rest_api_id = aws_api_gateway_rest_api.service1.id
}

# =====================================================================================
resource "aws_api_gateway_method" "product_post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.product.id
  rest_api_id   = aws_api_gateway_rest_api.service1.id
}

resource "aws_api_gateway_integration" "product_post" {
  http_method = aws_api_gateway_method.product_post.http_method
  resource_id = aws_api_gateway_resource.product.id
  rest_api_id = aws_api_gateway_rest_api.service1.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.microservice1_serverless.arn}/invocations"
}

resource "aws_lambda_permission" "allow_product_post" {
  statement_id  = "AllowAPIGatewayInvokeProductPost"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.microservice1_serverless.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.service1.execution_arn}/*/*"
}

# ======================================================================================
resource "aws_api_gateway_method" "product_get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.product.id
  rest_api_id   = aws_api_gateway_rest_api.service1.id
}

resource "aws_api_gateway_integration" "product_get" {
  http_method = aws_api_gateway_method.product_get.http_method
  resource_id = aws_api_gateway_resource.product.id
  rest_api_id = aws_api_gateway_rest_api.service1.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.microservice1_serverless.arn}/invocations"
}

resource "aws_lambda_permission" "allow_product_get" {
  statement_id  = "AllowAPIGatewayInvokeProductGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.microservice1_serverless.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.service1.execution_arn}/*/*"
}

# ===================================================================================================
resource "aws_api_gateway_method" "options_product" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.product.id
  rest_api_id   = aws_api_gateway_rest_api.service1.id
}

resource "aws_api_gateway_integration" "options_product" {
  http_method = aws_api_gateway_method.options_product.http_method
  resource_id = aws_api_gateway_resource.product.id
  rest_api_id = aws_api_gateway_rest_api.service1.id
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_product" {
  rest_api_id = aws_api_gateway_rest_api.service1.id
  resource_id = aws_api_gateway_resource.product.id
  http_method = aws_api_gateway_method.options_product.http_method
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

resource "aws_api_gateway_integration_response" "options_product" {
  rest_api_id = aws_api_gateway_rest_api.service1.id
  resource_id = aws_api_gateway_resource.product.id
  http_method = aws_api_gateway_method.options_product.http_method
  status_code = aws_api_gateway_method_response.options_product.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,GET,OPTIONS'"
  }
}

# ===================================================================================================
resource "aws_api_gateway_deployment" "service1_deployment" {
  rest_api_id = aws_api_gateway_rest_api.service1.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.product_get,
      aws_api_gateway_integration.product_post
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ======================================================================================================
resource "aws_api_gateway_stage" "service1" {
  deployment_id = aws_api_gateway_deployment.service1_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.service1.id
  stage_name    = "prod"
}