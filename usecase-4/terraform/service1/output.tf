output "api_url" {
  value = "${aws_api_gateway_stage.service1.invoke_url}"
}