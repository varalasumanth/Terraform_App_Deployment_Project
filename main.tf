locals {
  Name = "sumanth"
}

#vpc infrastructure
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${local.Name}-vpc"
  }
}

resource "aws_subnet" "sub1" {
  cidr_block              = "10.0.0.0/24"
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.Name}-sub1"
  }
}

resource "aws_subnet" "sub2" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.Name}-sub2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.Name}-igw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.Name}-rt"
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "websg" {
  name   = "web"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Webserver-sg"
  }
}

resource "aws_instance" "webserver1" {
  ami                    = "ami-00c6177f250e07ec1"
  instance_type          = "t2.micro"
  key_name               = "sumanth_keypair"
  vpc_security_group_ids = [aws_security_group.websg.id]
  subnet_id              = aws_subnet.sub1.id
  availability_zone      = "us-east-1a"
  user_data              = <<EOF
#!/bin/bash
sudo -i
yum update -y
yum install httpd git -y
service httpd start
chkconfig httpd on
git clone https://github.com/varalasumanth/FoodApp.git /var/www/html/
EOF
  tags = {
    Name = "web-server-1"
  }
}

resource "aws_instance" "webserver2" {
  ami                    = "ami-00c6177f250e07ec1"
  instance_type          = "t2.micro"
  key_name               = "sumanth_keypair"
  vpc_security_group_ids = [aws_security_group.websg.id]
  subnet_id              = aws_subnet.sub2.id
  availability_zone      = "us-east-1b"
  user_data              = <<EOF
#!/bin/bash
sudo -i
yum update -y
yum install httpd git -y
service httpd start
chkconfig httpd on
git clone https://github.com/varalasumanth/FoodApp.git /var/www/html/
EOF
  tags = {
    Name = "web-server-2"
  }
}
