provider "aws" {
    region = "ap-south-1"
}
//creating vpc 
resource "aws_vpc" "custom_vpc"{
    cidr_block = var.cidr_block
    enable_dns_support   = true
    enable_dns_hostnames = var.dns_hostnames
    
    tags = {
      "name" = "customVPC"
    }
}
//creating subnet 1 
resource "aws_subnet" "custom_subnet01" {
    vpc_id = aws_vpc.custom_vpc.id
    cidr_block = var.cidr_block_sub01
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true

    tags = { 
      Name = "Public-Subnet01"
      "kubernetes.io/cluster/dev-eks-cluster" = "shared" 
      "kubernetes.io/role/elb" = "1" 
    }
}
//creatin subnet 2
resource "aws_subnet" "custom_subnet02" { 
    vpc_id = aws_vpc.custom_vpc.id
    cidr_block = var.cidr_block_sub02
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true

    tags = {
      Name = "Public-Subnet02"
      "kubernetes.io/cluster/dev-eks-cluster" = "shared"
      "kubernetes.io/role/elb" = "1"
    }
}
//creating subnet 3 
resource "aws_subnet" "custom_subnet03" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.cidr_block_sub03
  availability_zone = "ap-south-1a"

  tags = { 
      Name = "Private-Subnet01"
      "kubernetes.io/cluster/dev-eks-cluster" = "shared"
      "kubernetes.io/role/internal-elb" = "1"
  }
}
//creating subnet 4 
resource "aws_subnet" "custom_subnet04"{
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.cidr_block_sub04
  availability_zone = "ap-south-1b"

  tags = { 
      Name = "Private-Subnet02"
      "kubernetes.io/cluster/dev-eks-cluster" = "shared"
      "kubernetes.io/role/internal-elb" = "1" 
  }
}

//creating internet gateway 
resource "aws_internet_gateway" "custom_IGW" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "customIG"
  }

}

//creating route table 
resource "aws_route_table" "custom_RT" {
    vpc_id = aws_vpc.custom_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.custom_IGW.id
    }

    tags = {
        Name = "customRT"
    }
}

//creating subnet association
resource "aws_route_table_association" "subnet_association01" {
  subnet_id      = aws_subnet.custom_subnet01.id
  route_table_id = aws_route_table.custom_RT.id
}
resource "aws_route_table_association" "subnet_association02" {
  subnet_id      = aws_subnet.custom_subnet02.id
  route_table_id = aws_route_table.custom_RT.id
}
resource "aws_eip" "nat-ip" {
}
resource "aws_nat_gateway" "custom_NAT" {
  allocation_id = aws_eip.nat-ip.id
  subnet_id = aws_subnet.custom_subnet01.id

  tags = {
    "name" = "custom_NAT"
  }
}
resource "aws_route_table" "custom_RT02" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.custom_NAT.id

  }
}
resource "aws_route_table_association" "subnet_association03" {
  subnet_id = aws_subnet.custom_subnet03.id
  route_table_id = aws_route_table.custom_RT02.id
}
resource "aws_route_table_association" "subnet_association04" {
  subnet_id = aws_subnet.custom_subnet04.id
  route_table_id = aws_route_table.custom_RT02.id
}