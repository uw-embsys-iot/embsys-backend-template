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
    values = ["YOUR-KEY-HERE"]
  }
}

# IOTEMBSYS: create a security group that limits ingress traffic to SSH and port 8080
# resource "aws_security_group" "allow_ssh_and_tcp" {
#
# }

resource "aws_instance" "app_server" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  key_name      = "vockey"
  # IOTEMBSYS: set the security group here, once created
  # vpc_security_group_ids = [aws_security_group.allow_ssh_and_tcp.id]

  tags = {
    Name = "AppServerInstance"
  }
}

# IOTEMBSYS: Create an output target that prints the instance public IP.
# output "instance_public_ip" {
#    
# }
