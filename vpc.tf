provider "aws" {
  // get this stuff from elsewhere, especially secret_key!
  //access_key = var.aws_access_key_id
  //secret_key = var.aws_secret_access_key
  region = "us-west-1"
}

resource "aws_vpc" "the_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.vpc_name
  }
}

// Internet gateway for the public subnet
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.the_vpc.id
  tags = {
    Name = "simon-test-terraform-igw"
  }
}

// Public subnet
resource "aws_subnet" "vpc_public_sn" {
  vpc_id = aws_vpc.the_vpc.id
  cidr_block = var.vpc_public_subnet_1_cidr
  availability_zone = lookup(var.availability_zone, var.vpc_region)
  tags = {
    Name = "simon-test-terraform-vpc_public_sn"
  }
}

// Private subnet
resource "aws_subnet" "vpc_private_sn" {
  vpc_id = aws_vpc.the_vpc.id
  cidr_block = var.vpc_private_subnet_1_cidr
  availability_zone = lookup(var.availability_zone, var.vpc_region)
  tags = {
    Name = "simon-test-terraform-vpc_private_sn"
  }
}

// Routing table for public subnet
resource "aws_route_table" "vpc_public_sn_rt" {

  vpc_id = aws_vpc.the_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
  tags = {
    Name = "simon-test-terraform-vpc_public_sn_rt"
  }
}

// Associate the routing table to public subnet
resource "aws_route_table_association" "vpc_public_sn_rt_assn" {
  subnet_id = aws_subnet.vpc_public_sn.id
  route_table_id = aws_route_table.vpc_public_sn_rt.id
}

// Security Group
resource "aws_security_group" "vpc_public_sg" {
  name = "pubic_sg"
  description = "demo public access security group"
  vpc_id = aws_vpc.the_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "10.0.0.0/8"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = [
      "10.0.0.0/24"]
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Name = "simon-test-terraform-pubic_sg"
  }
}

resource "aws_security_group" "vpc_private_sg" {
  name = "private_sg"
  description = "demo security group to access private ports"
  vpc_id = aws_vpc.the_vpc.id

  // allow ssh port within VPC
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "10.0.0.0/24"]
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Name = "private_sg"
  }
}

output "vpc_region" {
  value = var.vpc_region
}

output "vpc_id" {
  value = aws_vpc.the_vpc.id
}

output "vpc_public_sn_id" {
  value = aws_subnet.vpc_public_sn.id
}

output "vpc_private_sn_id" {
  value = aws_subnet.vpc_private_sn.id
}

output "vpc_public_sg_id" {
  value = aws_security_group.vpc_public_sg.id
}

output "vpc_private_sg_id" {
  value = aws_security_group.vpc_private_sg.id
}
