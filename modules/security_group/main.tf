provider "aws" {
  region = "ap-south-1"
}

//crating security group 
resource "aws_security_group" "EC2_SG" {
  name        = "EC2_SG"
  vpc_id      = var.sg_vpc_id

  tags = {
    Name = "EC2_SG"
  }
}
//inbound rules 
resource "aws_vpc_security_group_ingress_rule" "allow_all" {
  security_group_id = aws_security_group.EC2_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}
//outbound rules 
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.EC2_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
//outbond rules for ipv6
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.EC2_SG.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}