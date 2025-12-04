resource "aws_api_gateway_rest_api" "ecommerce" {
  name = "ecommerce"
}

# PRODUCT
resource "aws_api_gateway_resource" "products" {
  parent_id   = aws_api_gateway_rest_api.ecommerce.root_resource_id
  path_part   = "products"
  rest_api_id = aws_api_gateway_rest_api.ecommerce.id
}

# GET
resource "aws_api_gateway_method" "get_products" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.products.id
  rest_api_id   = aws_api_gateway_rest_api.ecommerce.id
}

resource "aws_api_gateway_integration" "get_products" {
  http_method = aws_api_gateway_method.get_products.http_method
  resource_id = aws_api_gateway_resource.products.id
  rest_api_id = aws_api_gateway_rest_api.ecommerce.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.product.arn}/invocations"
}

resource "aws_lambda_permission" "allow_get_products" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.product.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ecommerce.execution_arn}/*/*"
}

# POST
resource "aws_api_gateway_method" "post_products" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.products.id
  rest_api_id   = aws_api_gateway_rest_api.ecommerce.id
}

resource "aws_api_gateway_integration" "post_products" {
  http_method = aws_api_gateway_method.post_products.http_method
  resource_id = aws_api_gateway_resource.products.id
  rest_api_id = aws_api_gateway_rest_api.ecommerce.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.product.arn}/invocations"
}

resource "aws_lambda_permission" "allow_post_products" {
  statement_id  = "AllowAPIGatewayInvokePostProduct"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.product.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ecommerce.execution_arn}/*/*"
}

# PUT
resource "aws_api_gateway_method" "put_products" {
  authorization = "NONE"
  http_method   = "PUT"
  resource_id   = aws_api_gateway_resource.products.id
  rest_api_id   = aws_api_gateway_rest_api.ecommerce.id
}

resource "aws_api_gateway_integration" "put_products" {
  http_method = aws_api_gateway_method.put_products.http_method
  resource_id = aws_api_gateway_resource.products.id
  rest_api_id = aws_api_gateway_rest_api.ecommerce.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.product.arn}/invocations"
}

resource "aws_lambda_permission" "allow_put_products" {
  statement_id  = "AllowAPIGatewayInvokePutProduct"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.product.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ecommerce.execution_arn}/*/*"
}


# DELETE
resource "aws_api_gateway_method" "delete_products" {
  authorization = "NONE"
  http_method   = "DELETE"
  resource_id   = aws_api_gateway_resource.products.id
  rest_api_id   = aws_api_gateway_rest_api.ecommerce.id
}

resource "aws_api_gateway_integration" "delete_products" {
  http_method = aws_api_gateway_method.delete_products.http_method
  resource_id = aws_api_gateway_resource.products.id
  rest_api_id = aws_api_gateway_rest_api.ecommerce.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.product.arn}/invocations"
}

resource "aws_lambda_permission" "allow_delete_products" {
  statement_id  = "AllowAPIGatewayInvokeDeleteProduct"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.product.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ecommerce.execution_arn}/*/*"
}

# OPTIONS
resource "aws_api_gateway_method" "options_products" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.products.id
  rest_api_id   = aws_api_gateway_rest_api.ecommerce.id
}

resource "aws_api_gateway_integration" "options_products" {
  http_method = aws_api_gateway_method.options_products.http_method
  resource_id = aws_api_gateway_resource.products.id
  rest_api_id = aws_api_gateway_rest_api.ecommerce.id
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_products" {
  rest_api_id = aws_api_gateway_rest_api.ecommerce.id
  resource_id = aws_api_gateway_resource.products.id
  http_method = aws_api_gateway_method.options_products.http_method
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

resource "aws_api_gateway_integration_response" "options_products" {
  rest_api_id = aws_api_gateway_rest_api.ecommerce.id
  resource_id = aws_api_gateway_resource.products.id
  http_method = aws_api_gateway_method.options_products.http_method
  status_code = aws_api_gateway_method_response.options_products.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
  }
}


# ORDERS
resource "aws_api_gateway_resource" "orders" {
  parent_id   = aws_api_gateway_rest_api.ecommerce.root_resource_id
  path_part   = "orders"
  rest_api_id = aws_api_gateway_rest_api.ecommerce.id
}

# POST
resource "aws_api_gateway_method" "post_orders" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.orders.id
  rest_api_id   = aws_api_gateway_rest_api.ecommerce.id
}

resource "aws_api_gateway_integration" "post_orders" {
  http_method = aws_api_gateway_method.post_orders.http_method
  resource_id = aws_api_gateway_resource.orders.id
  rest_api_id = aws_api_gateway_rest_api.ecommerce.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.order.arn}/invocations"
}

resource "aws_lambda_permission" "allow_post_orders" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.order.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ecommerce.execution_arn}/*/*"
}

# GET
resource "aws_api_gateway_method" "get_orders" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.orders.id
  rest_api_id   = aws_api_gateway_rest_api.ecommerce.id
}

resource "aws_api_gateway_integration" "get_orders" {
  http_method = aws_api_gateway_method.get_orders.http_method
  resource_id = aws_api_gateway_resource.orders.id
  rest_api_id = aws_api_gateway_rest_api.ecommerce.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.order.arn}/invocations"
}

resource "aws_lambda_permission" "allow_get_orders" {
  statement_id  = "AllowAPIGatewayInvokeGetOrders"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.order.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ecommerce.execution_arn}/*/*"
}

# OPTIONS
resource "aws_api_gateway_method" "options_orders" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.orders.id
  rest_api_id   = aws_api_gateway_rest_api.ecommerce.id
}

resource "aws_api_gateway_integration" "options_orders" {
  http_method = aws_api_gateway_method.options_orders.http_method
  resource_id = aws_api_gateway_resource.orders.id
  rest_api_id = aws_api_gateway_rest_api.ecommerce.id
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_orders" {
  rest_api_id = aws_api_gateway_rest_api.ecommerce.id
  resource_id = aws_api_gateway_resource.orders.id
  http_method = aws_api_gateway_method.options_orders.http_method
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

resource "aws_api_gateway_integration_response" "options_orders" {
  rest_api_id = aws_api_gateway_rest_api.ecommerce.id
  resource_id = aws_api_gateway_resource.orders.id
  http_method = aws_api_gateway_method.options_orders.http_method
  status_code = aws_api_gateway_method_response.options_orders.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
  }
}


# DEPLOYMENT
resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.ecommerce.id

  depends_on = [
    aws_api_gateway_integration.post_products,
    aws_api_gateway_integration.put_products,
    aws_api_gateway_integration.delete_products,
    aws_api_gateway_integration.get_products,
    aws_api_gateway_integration.options_products,
    aws_api_gateway_integration.post_orders,
    aws_api_gateway_integration.get_orders,
    aws_api_gateway_integration.options_orders
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.get_products.id,
      aws_api_gateway_integration.post_orders.id,
      aws_api_gateway_integration.get_orders.id,
      aws_api_gateway_integration.options_orders.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "eccommerce" {
  deployment_id = aws_api_gateway_deployment.deploy.id
  rest_api_id   = aws_api_gateway_rest_api.ecommerce.id
  stage_name    = "dev"
}