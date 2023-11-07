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

  # TODO: Remove when creating course content
  profile = "skobovm"
}

# Note: if not accessing AWS through Vocareum, another SSH keypair
# must be generated for having access to EC2 instances. This key must
# then be used with the SSH client. See:
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html
data "aws_key_pair" "ssh_key" {
  key_name           = "ec2_access"
  include_public_key = true

  filter {
    name   = "key-pair-id"
    # IOTEMBSYS: Copy the keypair ID from the current AWS lab.
    # Note: this changes with every new Vocareum lab!
    # This can be found under the EC2 page, in the "Key Pairs" section.
    
    # values = ["key-06fb9f6f5fe337b27"]
    # TODO: remove the personal key when creating github classroom modules.
    values = ["key-06c68812aa9271f80"]
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
    from_port        = 4242
    to_port          = 4242
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Inbound HTTP"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Inbound HTTP"
    from_port        = 80
    to_port          = 80
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
  # TODO: Remove the personal key name
  # key_name      = "vockey"
  key_name      = "ec2_access"
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  # TODO(mskobov): Install venv package and python/other packages
  # user_data = <<-EOL
  # #!/bin/bash -xe
  # python3 -m venv .venv
  # source .venv/bin/activate
  # pip install -r /home/ubuntu/requirements.txt
  # python3 /home/ubuntu/http_server.py
  # EOL

  # Copy the file to the server
  provisioner "file" {
    source = "http_server.py"
    destination = "/home/ubuntu/http_server.py"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("labsuser.pem")
      host     = aws_instance.app_server.public_ip
    }
  }

  provisioner "file" {
    source = "requirements.txt"
    destination = "/home/ubuntu/requirements.txt"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("labsuser.pem")
      host     = aws_instance.app_server.public_ip
    }
  }

  tags = {
    Name = "AppServerInstance"
  }
}

# Show details from applying
output "instance_public_ip" {
    value = aws_instance.app_server.public_ip
    description = "AWS EC2 Instance Public IP"
}
