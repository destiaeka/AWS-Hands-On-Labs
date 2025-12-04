output "api_url" {
  value = "${aws_api_gateway_stage.chatbot.invoke_url}/chatbot"
}