# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true # Internal domain name
  enable_dns_hostnames = true # Internal host name

  tags = {
    Name = "${var.environment}-vpc"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "igw"{
  vpc_id= aws_vpc.vpc.id
  tags = {
    Name = "${var.environment}-igw"
  }
}

# Public Subnet 1
resource "aws_subnet" "snpuba"{
  vpc_id=aws_vpc.vpc.id
  cidr_block= var.cidr_subnet1
  availability_zone="us-east-1a"
  tags = {
    Name = "${var.environment}-snpuba"
  }
}

# Public Subnet 2
resource "aws_subnet" "snpubb"{
  vpc_id=aws_vpc.vpc.id
  cidr_block=var.cidr_subnet2
  availability_zone="us-east-1b"
  tags = {
    Name = "${var.environment}-snpubb"
  }
}

# Private Subnet 1
resource "aws_subnet" "snpriva"{
  vpc_id=aws_vpc.vpc.id
  cidr_block= var.cidr_subnet3
  availability_zone="us-east-1a"
  tags = {
    Name = "${var.environment}-snpriva"
  }
}

# Private Subnet 2
resource "aws_subnet" "snprivb"{
  vpc_id=aws_vpc.vpc.id
  cidr_block=var.cidr_subnet4
  availability_zone="us-east-1b"
  tags = {
    Name = "${var.environment}-snprivb"
  }
}

# Route table
resource "aws_route_table" "pubrt"{
  vpc_id=aws_vpc.vpc.id
  route{
    cidr_block="0.0.0.0/0"
    gateway_id=aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.environment}-pubrt"
  }
}

# we have to associate the route table with the subnet1
resource "aws_route_table_association" "rtapuba"{
  subnet_id=aws_subnet.snpuba.id
  route_table_id=aws_route_table.pubrt.id
}

# we have to associate the route table with the subnet2
resource "aws_route_table_association" "rtapubb"{
  subnet_id=aws_subnet.snpubb.id
  route_table_id=aws_route_table.pubrt.id
}

# Network ACL: we just allow everything
resource "aws_network_acl" "nacl" {
  vpc_id = aws_vpc.vpc.id

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
    Name = "${var.environment}-nacl"
  }
}


# Create a Public IP for the NAT Gateway
resource "aws_eip" "nateip" {
  vpc = true
tags = {
    Name = "${var.environment}-nateip"
  }
}

# Create a NAT Gateway and associate to public subnet in az a
resource "aws_nat_gateway" "natgw" {
  depends_on = [aws_internet_gateway.igw]
  allocation_id = aws_eip.nateip.id
  subnet_id     = aws_subnet.snpuba.id
  tags = {
    Name = "${var.environment}-natgw"
  }
}

# Create private route table
resource "aws_route_table" "privrt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }
  
  tags = {
    Name = "${var.environment}-privrt"
  }
}
# we associate the private route table with private subnet1
resource "aws_route_table_association" "rtapriva" {
  subnet_id      = aws_subnet.snpriva.id
  route_table_id = aws_route_table.privrt.id
}
# we associate the private route table with private subnet2
resource "aws_route_table_association" "rtaprivb" {
  subnet_id      = aws_subnet.snprivb.id
  route_table_id = aws_route_table.privrt.id
}


# ---------------------------------------------------------------------------------------------------------------------
# Create three VPC endpoints for AWS Systems Manager
#
# References: 
# - https://aws.amazon.com/premiumsupport/knowledge-center/ec2-systems-manager-vpc-endpoints/
# - https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html#sysman-setting-up-vpc-create 
# ---------------------------------------------------------------------------------------------------------------------

# VPC endpoint for the Systems Manager service
resource "aws_vpc_endpoint" "ssm_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.snpriva.id, aws_subnet.snprivb.id]
  security_group_ids  = [var.ec2sgid]
  private_dns_enabled = true

  tags = {
    Name = "${var.environment}-ssm"
  }
}

# VPC endpoint for SSM Agent to make calls to the Systems Manager service
resource "aws_vpc_endpoint" "ec2_messages_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.snpriva.id, aws_subnet.snprivb.id]
  security_group_ids  = [var.ec2sgid]
  private_dns_enabled = true

  tags = {
    Name = "${var.environment}-ec2messages"
  }
}

# VPC endpoint for connecting to EC2 instances through a secure data channel using Session Manager
resource "aws_vpc_endpoint" "ssm_messages_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.snpriva.id, aws_subnet.snprivb.id]
  security_group_ids  = [var.ec2sgid]
  private_dns_enabled = true

  tags = {
    Name = "${var.environment}-ssmmessages"
  }
}

