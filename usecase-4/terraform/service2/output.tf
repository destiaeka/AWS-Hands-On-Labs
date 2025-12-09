output "api_url" {
  value = "${aws_api_gateway_stage.service2.invoke_url}"
}