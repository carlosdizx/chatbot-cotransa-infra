resource "aws_instance" "chatbot" {
  ami                    = var.details_instances.ami
  instance_type          = var.details_instances.type
  key_name               = aws_key_pair.deployer_key.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg_public_instance.id]
  user_data                   = file("scripts/python_script.sh")
  user_data_replace_on_change = true
  tags = {
    Name = "Chatbot Instance"
  }
}

