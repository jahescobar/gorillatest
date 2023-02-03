# Define local group from subnets created
locals {
    ec2subnets = [var.subnetc,var.subnetd]
}

# Generate a keypair
resource "tls_private_key" "keypair" {
    algorithm = "RSA"
    rsa_bits = 4096
}

# Create Keypair
resource "aws_key_pair" "keypair" {
    key_name = "lxkp"
    public_key = tls_private_key.keypair.public_key_openssh
}

# Save keypair
resource "local_file" "sshkey"{
    filename = "${aws_key_pair.keypair.key_name}.pem"
    content = tls_private_key.keypair.private_key_pem
}

# Get most recent ami from amazon
data "aws_ami" "amzn2" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-5*"]  # amzn2-ami-kernel-4* for previously kernel type
    }
    
}

# Create Instances
resource "aws_instance" "servers" {
    count = var.ec2servers
    ami = data.aws_ami.amzn2.id
    instance_type = var.instancetype
    subnet_id = element(local.ec2subnets, count.index)
    vpc_security_group_ids = [aws_security_group.ec2sg.id]
    associate_public_ip_address = var.addpubip
    source_dest_check = false
    iam_instance_profile = aws_iam_instance_profile.ssmrolprof.name 
    key_name = aws_key_pair.keypair.key_name
    user_data = file("modules/ec2/userdata.sh")
    root_block_device {
      volume_size = var.rootvolsize
      volume_type = var.rootvoltype
      delete_on_termination = true
    }

    tags = {
        Name = "${var.environment}-${count.index+1}"
    }

}

# Create EC2 Security Group
resource "aws_security_group" "ec2sg" {
  name = "${var.environment}-ec2sg"
  description = "Allow incomming TCP connections"
  vpc_id = var.vpcid

# SSH disabled enabled access by ssm
#  ingress {
#    from_port = 22
#    to_port = 22
#    protocol = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#    description = "Allow all SSH Connection"
#  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming LB Connection"
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming traffic for SSM/EC2 endpoints"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-ec2sg"
  }
}

# Configure ssm agent connection
# Create ssm role
resource "aws_iam_role" "ssmrole" {
  name = "${var.environment}-ssmrole"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": {
      "Effect": "Allow",
      "Principal": {"Service": "ssm.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  }
EOF
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ssmrolatt" {
  role       = aws_iam_role.ssmrole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create a instance profile with the ssmrole
resource "aws_iam_instance_profile" "ssmrolprof" {
name = "${var.environment}-ssmrolprof"
role = aws_iam_role.ssmrole.name
}