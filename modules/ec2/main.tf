provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "EC2Instance" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  user_data = file(var.user_data)
  root_block_device {
    volume_size = var.volume_size
  }
  
}

