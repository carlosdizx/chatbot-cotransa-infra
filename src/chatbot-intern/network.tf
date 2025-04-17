resource "aws_vpc" "vpc_main" {
  cidr_block = var.vpc_main_cidr
  tags = {
    Name = "Vpc Main",
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = var.subnets_main_cidr[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public subnet",
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = var.subnets_main_cidr[1]
  tags = {
    Name = "Private subnet",
  }
  depends_on = [
    aws_subnet.public_subnet
  ]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_main.id
  tags = {
    Name = "IGW VPC MAIN"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc_main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "Route Table"
  }
}

resource "aws_route_table_association" "crt_public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg_public_instance" {
  name        = "Public instance SG"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc_main.id

  tags = {
    Name = "Allow SSH and anyevery"
  }

  ingress {
    description = "SSH inbound"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    description = "HTTP over internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Streamlit over internet"
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Streamlit over internet"
    from_port   = 8503
    to_port     = 8503
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP over internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}