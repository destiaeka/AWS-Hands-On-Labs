output "api_url" {
  value = "${aws_api_gateway_stage.sendmassage.invoke_url}"
}