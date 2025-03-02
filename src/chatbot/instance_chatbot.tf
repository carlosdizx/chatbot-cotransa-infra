resource "aws_instance" "chatbot" {
  ami                         = var.details_instances.ami
  instance_type               = var.details_instances.type
  tags = {
    Name = "Chatbot Instance"
  }
}

