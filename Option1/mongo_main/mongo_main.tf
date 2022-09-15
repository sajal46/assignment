provider "aws" {
  region  = "ap-south-1"
  profile = "personal"
}


resource "aws_instance" "mongo" {
    ami = "ami-068d43a544160b7ef"
    instance_type = "t2.micro"
    user_data = "${file("mongo_main.sh")}"
    key_name = "mongo"

    vpc_security_group_ids = [
      aws_security_group.mongo_main.id
    ]

    root_block_device {
      volume_size           = "8"
      volume_type           = "gp2"
      delete_on_termination = true
    }
    tags = {
		Name = "main_mongo"	
    }
}

resource "aws_security_group" "mongo" {
  name        = "Mongo security group"
  description = "Allow 27017 inbound request"
  vpc_id      = var.vpc_id

  ingress {
    description      = "db access from my ip"
    from_port        = 27017
    to_port          = 27017               
    protocol         = "tcp"
    cidr_blocks      =  ["0.0.0.0/0"]
    ipv6_cidr_blocks =  ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mongo"
  }
}

output "ec2-ip" {
  value = aws_instance.mo.public_ip
}

output "sg-id" {
  value = aws_security_group.mongo.id
}