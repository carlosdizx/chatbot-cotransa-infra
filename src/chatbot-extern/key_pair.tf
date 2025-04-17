resource "tls_private_key" "keys" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "random_uuid" "uuid" {}

resource "local_file" "private_key_file" {
  content  = tls_private_key.keys.private_key_pem
  filename = "${path.module}/output/private_key.pem"
}

resource "local_file" "public_key_file" {
  content  = tls_private_key.keys.public_key_openssh
  filename = "${path.module}/output/public_key.pub"
}

resource "aws_key_pair" "deployer_key" {
  key_name   = "deployer_key-${random_uuid.uuid.result}"
  public_key = tls_private_key.keys.public_key_openssh
}