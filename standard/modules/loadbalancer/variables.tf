variable "dnsname" {
    description = "Dns Name Public"
    type = string
}

variable "hostname" {
    description = "Hostname for the load balancer"
    type = string
}

variable "vpcid" {
    description = "vpc created identification"
    type = string
}

variable environment {
    description = "Environment of the solution"
    type = string
}

variable "subneta" {
    description = "subnet variable az1"
    type = string
}

variable "subnetb" {
    description = "subnet variable az2"
    type = string
}

variable "ec2servers" {
    description = "Quantity of EC2 Instances"
    type = number
}

variable "serversid" {
    description = "List of servers id"
    type = list
}