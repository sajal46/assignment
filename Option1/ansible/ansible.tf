provider "aws" {
  region  = "ap-south-1"
  profile = "personal"
}


resource "aws_instance" "ansible" {
    ami = "ami-068257025f72f470d"
    instance_type = "t2.micro"
    user_data =  "${file("ansible.sh")}"
    key_name = "ansible"

    vpc_security_group_ids = [
      aws_security_group.ansible.id
    ]

    root_block_device {
      volume_size           = "8"
      volume_type           = "gp2"
      delete_on_termination = true
    }
    tags = {
		Name = "ansible"	
    }
}

resource "aws_security_group" "ansible" {
  name        = "Ansible security group"
  description = "Allow ssh inbound request"
  vpc_id      = var.vpc_id

  ingress {
    description      = "ssh from anywhere"
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
    Name = "Ansible"
  }
}

output "ec2-ip" {
  value = aws_instance.ansible.public_ip
}

output "sg-id" {
  value = aws_security_group.ansible.id
}
