provider "aws" {
  region  = "ap-south-1"
  profile = "personal"
}


resource "aws_instance" "mongo_replica" {
    count = 2
    ami = "ami-068257025f72f470d"
    instance_type = "t2.micro"
    user_data = "${file("mongo_replica.sh")}"
    key_name = "ansible"

    vpc_security_group_ids = [
      aws_security_group.mongo.id
    ]

    root_block_device {
      volume_size           = "8"
      volume_type           = "gp2"
      delete_on_termination = true
    }
    tags = {
		Name = "mongo_replica-${count.index}"	
    }
}

output "ec2-ip" {
  value = aws_instance.mongo_replica.public_ip
}

output "sg-id" {
  value = aws_security_group.mongo.id
}