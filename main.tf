terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

# Note: if not accessing AWS through Vocareum, another SSH keypair
# must be generated for having access to EC2 instances. This key must
# then be used with the SSH client. See:
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html
data "aws_key_pair" "ssh_key" {
  key_name           = "vockey"
  include_public_key = true

  filter {
    name   = "key-pair-id"
    # IOTEMBSYS: Copy the keypair ID from the current AWS lab.
    # Note: this changes with every new Vocareum lab!
    values = ["key-081527ae1e616f783"]
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Inbound"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  key_name      = "vockey"
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  tags = {
    Name = "AppServerInstance"
  }
}

# Show details from applying
output "instance_public_ip" {
    value = aws_instance.app_server.public_ip
    description = "AWS EC2 Instance Public IP"
}
