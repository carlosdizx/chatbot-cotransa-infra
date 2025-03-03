resource "aws_instance" "chatbot" {
  ami           = var.details_instances.ami
  instance_type = var.details_instances.type
  key_name      = aws_key_pair.deployer_key.key_name
  tags = {
    Name = "Chatbot Instance"
  }
}

