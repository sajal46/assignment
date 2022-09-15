provider "aws" {
  region  = "ap-south-1"
  profile = "personal"
}


resource "aws_instance" "prometheus" {
  ami           = "ami-068257025f72f470d"
  instance_type = "t2.micro"
  key_name      = "prometheus"
  user_data     = file("prometheus.sh")

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
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "prometheus server ssh access"
    from_port        = 22
    to_port          = 22
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
    Name = "prometheus"
  }
}

output "ec2-ip-prometheus" {
  value = aws_instance.prometheus.public_ip
}

output "sg-id-prometheus" {
  value = aws_security_group.prometheus.id
}


resource "aws_instance" "ansible" {
  ami           = "ami-068257025f72f470d"
  instance_type = "t2.micro"
  user_data     = file("ansible.sh")
  key_name      = "ansible"

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
    Name = "Ansible"
  }
}

output "ec2-ip-ansible" {
  value = aws_instance.ansible.public_ip
}

output "sg-id-ansible" {
  value = aws_security_group.ansible.id
}

resource "aws_instance" "mongo_main" {
  ami           = "ami-06489866022e12a14"
  instance_type = "t2.micro"
  user_data     = file("mongo_main.sh")
  key_name      = "mongo"

  vpc_security_group_ids = [
    aws_security_group.mongo.id
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
    description      = "ssh from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups =  [aws_security_group.ansible.id]
   }  

  ingress {
    description      = "db access from my ip"
    from_port        = 27017
    to_port          = 27017
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
    Name = "mongo"
  }
}

output "sg-id-mongo_main" {
  value = aws_security_group.mongo.id
}

resource "aws_instance" "mongo_replica_1" {
  ami           = "ami-06489866022e12a14"
  instance_type = "t2.micro"
  user_data     = file("mongo_replica.sh")
  key_name      = "mongo"

  vpc_security_group_ids = [
    aws_security_group.mongo.id
  ]

  root_block_device {
    volume_size           = "8"
    volume_type           = "gp2"
    delete_on_termination = true
  }
  tags = {
    Name = "mongo_replica-1"
  }
}


resource "aws_instance" "mongo_replica_2" {
  ami           = "ami-06489866022e12a14"
  instance_type = "t2.micro"
  user_data     = file("mongo_replica.sh")
  key_name      = "mongo"

  vpc_security_group_ids = [
    aws_security_group.mongo.id
  ]

  root_block_device {
    volume_size           = "8"
    volume_type           = "gp2"
    delete_on_termination = true
  }
  tags = {
    Name = "mongo_replica-2"
  }
}

output "privateip-mongo_main" {
    value = aws_instance.mongo_main.private_ip
}
output "privateip-mongo_replica_1" {
    value = aws_instance.mongo_main.private_ip
}
output "privateip-mongo_replica_2" {
    value = aws_instance.mongo_main.private_ip
}

