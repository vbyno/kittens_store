provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "dogs_vpc" {
  # Referencing the cidr_block variable allows the network address
  # to be changed without modifying the configuration.
  cidr_block = var.cidr_block

  tags = {
    Name = "dogs-shop-vpc"
  }
}

resource "aws_internet_gateway" "dogs_ig" {
  vpc_id = aws_vpc.dogs_vpc.id

  tags = {
    Name = "dogs-ig"
  }
}

resource "aws_route_table" "dogs_route_table" {
  vpc_id = aws_vpc.dogs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dogs_ig.id
  }

  # route {
  #   ipv6_cidr_block        = "::/0"
  #   egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  # }

  tags = {
    Name = "dogs-route-table"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "dogs_subnet" {
  count = length(data.aws_availability_zones.available.names)

  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  vpc_id     = aws_vpc.dogs_vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, count.index + 1)

  tags = {
    Name = "dogs-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "dogs_route_table_association" {
  count = length(aws_subnet.dogs_subnet)

  route_table_id = aws_route_table.dogs_route_table.id
  subnet_id      = element(aws_subnet.dogs_subnet, count.index).id
}

resource "aws_key_pair" "aws_key" {
  key_name   = "key_name_prefix"
  public_key = trimspace(file("~/.ssh/aws_key.pub"))
}

data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

resource "aws_security_group" "ec2_security_group" {
  name        = "ec2_security_group"
  description = "Allow SSH from public IP and HTTP for everyone"
  vpc_id      = aws_vpc.dogs_vpc.id

  ingress {
    description      = "SSH from Local Machine"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${jsondecode(data.http.my_public_ip.body).ip}/32"]
    # ipv6_cidr_blocks = [aws_vpc.dogs_vpc.ipv6_cidr_block]
  }

  ingress {
    description      = "HTTP from all over internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ec2_security_group"
  }
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Canonical
}

resource "aws_instance" "dogs_server" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  associate_public_ip_address = true

  key_name = aws_key_pair.aws_key.key_name
  subnet_id = element(aws_subnet.dogs_subnet, 0).id

  vpc_security_group_ids = [
    aws_security_group.ec2_security_group.id
  ]

  tags = {
    Name = "dogs-server"
  }
}
