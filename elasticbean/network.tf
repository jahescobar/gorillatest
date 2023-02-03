# VPC
resource "aws_vpc" "ebvpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true # Internal domain name
  enable_dns_hostnames = true # Internal host name

  tags = {
    Name = "ebvpc"
  }
}


#Internet Gateway
resource "aws_internet_gateway" "ebigw"{
  vpc_id = aws_vpc.ebvpc.id
tags = {
    Name = "ebigw"
  }
}

#Subnet1
resource "aws_subnet" "ebsnpub1"{
  vpc_id = aws_vpc.ebvpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-east-1a"
tags = {
    Name = "ebsnpub1"
  }
}

#Subnet2
resource "aws_subnet" "ebsnpub2"{
  vpc_id = aws_vpc.ebvpc.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "us-east-1b"
tags = {
    Name = "ebsnpub2"
  }
}

#Route table
resource "aws_route_table" "ebrt"{
  vpc_id = aws_vpc.ebvpc.id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ebigw.id
  }
  tags = {
    Name = "ebrt"
  }
}

#we have to associate the route table with the subnets
resource "aws_route_table_association" "ebrta"{
  subnet_id = aws_subnet.ebsnpub1.id
  route_table_id = aws_route_table.ebrt.id
}

resource "aws_route_table_association" "ebrtb"{
  subnet_id = aws_subnet.ebsnpub2.id
  route_table_id = aws_route_table.ebrt.id
}

# Network ACL: we just allow everything
resource "aws_network_acl" "ebnacl" {
  vpc_id = aws_vpc.ebvpc.id

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "ebnacl"
  }
}

