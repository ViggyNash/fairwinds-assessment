### Metadata
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

## Locals

locals{
  public_subnet_cidr = "172.16.10.0/24"
}

## Data Sources
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


## Networking
resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# resource "aws_route_table_association" "gw" {
#   gateway_id     = aws_internet_gateway.gw.id
#   route_table_id = aws_vpc.main.main_route_table_id
# }

resource "aws_route" "route_gw" {
  route_table_id            = aws_vpc.main.main_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.gw.id
}

resource "aws_subnet" "public-1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.public_subnet_cidr
  availability_zone = "us-west-1b"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow web traffic and ssh for admin."
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["76.104.40.126/32"]
  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

resource "aws_eip" "public_ip" {
  instance = aws_instance.test.id
}

## Instance
resource "aws_instance" "test" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public-1b.id
  security_groups             = [ aws_security_group.web.id ]
  key_name                    = "viggy-login"

  tags = {
    Name = "Fairwinds Assessment Host"
  }

  user_data = <<-EOH

  !#/bin/bash
  apt-get update
  apt-get install 

  EOH

}

