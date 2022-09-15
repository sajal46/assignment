provider "aws" {
  region  = "ap-south-1"
  profile = "personal"
}


resource "aws_instance" "prometheus" {
    ami = "ami-068257025f72f470d"
    instance_type = "t2.micro"
    key_name = "prometheus"
    user_data = "${file("prometheus.sh")}"

    vpc_security_group_ids = [
      aws_security_group.prometheus.id
    ]

    root_block_device {
      volume_size           = "8"
      volume_type           = "gp2"
      delete_on_termination = true
    }
    tags = {
		Name = "prometheus"	
    }
}

resource "aws_security_group" "prometheus" {
  name        = "prometheus security group"
  description = "Allow ssh inbound request"
  vpc_id      = var.vpc_id

  ingress {
    description      = "prometheus server  mectrics access"
    from_port        = 9090
    to_port          = 9090             
    protocol         = "tcp"
    cidr_blocks      =  ["0.0.0.0/0"]
    ipv6_cidr_blocks =  ["::/0"]
  }

  ingress {
    description      = "prometheus server ssh access"
    from_port        = 22
    to_port          = 22               
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
    Name = "prometheus"
  }
}

output "ec2-ip" {
  value = aws_instance.prometheus.public_ip
}

output "sg-id" {
  value = aws_security_group.prometheus.id
}
