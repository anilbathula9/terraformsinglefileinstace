provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA6NOC7XU5DIPGIY25"
  secret_key = "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"
}
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
      Name = "anil"
  }
}
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "public_subnet"
  }
}
resource "aws_route_table" "public_routetable" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IG.id
  }
  tags = {
    "Name" = "public_routetable"
  }
}
resource "aws_internet_gateway" "IG" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "anil_IGW"
  }
}
resource "aws_route_table_association" "route_table_association" {
  route_table_id = aws_route_table.public_routetable.id
  subnet_id = aws_subnet.public.id
}
resource "aws_security_group" "SG" {
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]  #[aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
resource "aws_instance" "ec2_instance" {
  ami = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  key_name = "jai"
  security_groups = [ aws_security_group.SG.id ]
  subnet_id = aws_subnet.public.id
  
  tags = {
    "Name" = "anil_instance"
  }
}