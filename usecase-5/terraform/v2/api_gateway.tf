# ============================================================================================
resource "aws_api_gateway_rest_api" "sendmassage" {
  name = "sendmassage"
}

# ==========================================================================================
resource "aws_api_gateway_resource" "sendmassage" {
  parent_id   = aws_api_gateway_rest_api.sendmassage.root_resource_id
  path_part   = "send-massage"
  rest_api_id = aws_api_gateway_rest_api.sendmassage.id
}

# ===========================================================================================
resource "aws_api_gateway_method" "post_sendmassage" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.sendmassage.id
  rest_api_id   = aws_api_gateway_rest_api.sendmassage.id
}

resource "aws_api_gateway_integration" "post_sendmassage" {
  http_method = aws_api_gateway_method.post_sendmassage.http_method
  resource_id = aws_api_gateway_resource.sendmassage.id
  rest_api_id = aws_api_gateway_rest_api.sendmassage.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.massage_send.arn}/invocations"
}

# ============================================================================================
resource "aws_api_gateway_method" "options_sendmassage" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.sendmassage.id
  rest_api_id   = aws_api_gateway_rest_api.sendmassage.id
}

resource "aws_api_gateway_integration" "options_sendmassage" {
  http_method  = aws_api_gateway_method.options_sendmassage.http_method
  resource_id  = aws_api_gateway_resource.sendmassage.id
  rest_api_id  = aws_api_gateway_rest_api.sendmassage.id
  type         = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_sendmassage" {
  rest_api_id = aws_api_gateway_rest_api.sendmassage.id
  resource_id = aws_api_gateway_resource.sendmassage.id
  http_method = aws_api_gateway_method.options_sendmassage.http_method
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

resource "aws_api_gateway_integration_response" "options_sendmassage" {
  rest_api_id = aws_api_gateway_rest_api.sendmassage.id
  resource_id = aws_api_gateway_resource.sendmassage.id
  http_method = aws_api_gateway_method.options_sendmassage.http_method
  status_code = aws_api_gateway_method_response.options_sendmassage.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,GET,OPTIONS'"
  }
}

# ============================================================================================
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.massage_send.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.sendmassage.execution_arn}/*/*"
}

# ==========================================================================================
resource "aws_api_gateway_deployment" "sendmassage_deployment" {
  rest_api_id = aws_api_gateway_rest_api.sendmassage.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.post_sendmassage,
      aws_api_gateway_integration.options_sendmassage
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ========================================================================================
resource "aws_api_gateway_stage" "sendmassage" {
  deployment_id = aws_api_gateway_deployment.sendmassage_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.sendmassage.id
  stage_name    = "prod"
}