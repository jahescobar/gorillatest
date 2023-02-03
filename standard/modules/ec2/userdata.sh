#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker 
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo systemctl enable docker

# Install ssm support connection
#sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
#sudo yum install -y https://s3.us-east-1.amazonaws.com/amazon-ssm-us-east-1/latest/linux_amd64/amazon-ssm-agent.rpm
#sudo systemctl start amazon-ssm-agent

# Install nginx
sudo amazon-linux-extras enable epel
sudo yum install epel-release
sudo yum install nginx
sudo systemctl enable --now nginx
