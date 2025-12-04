output "api_url" {
  value = "${aws_api_gateway_stage.serverless.invoke_url}/serverless"
}