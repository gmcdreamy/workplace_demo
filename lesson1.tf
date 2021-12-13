terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "ceutec"
  region  = "us-east-2"
}

#data "template_file" "user_data_hw" {
#  template = <<EOF
##!/bin/bash -xe
#apt-get update -y
#apt-get install -y awscli docker.io jq
#EOF
#}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls-Anibal"
  description = "Allow TLS inbound traffic"

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls-Anibal"
  }
}

resource "aws_launch_template" "foobar" {
  name_prefix   = "anibal-terraform"
  image_id      = "ami-002068ed284fb165b"
  instance_type = "t2.micro"
  security_group_names = [aws_security_group.allow_tls.name]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 8
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Anibal-Terrafrom"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "Anibal-Terraform"
    }
  }

  iam_instance_profile {
    name = "List_S3"
  }
  #user_data = "${base64encode(data.template_file.user_data_hw.rendered)}"
  user_data = filebase64("${path.module}/script.sh")
#  user_data = "${base64encode(<<EOF
# #! /bin/sh
#sudo yum update
#sudo yum install links2
#sudo yum install apache
#echo "Hola Anibal !!!"
#touch /home/ec2-user/anibal.txt
#EOF
#)}"
}

resource "aws_autoscaling_group" "bar" {
  availability_zones = ["us-east-2a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.foobar.id
    version = "$Latest"
  }
}

