variable "ec2servers" {
    description = "Quantity of EC2 Instances"
    type = number
    default = 2
}

variable "instancetype" {
    description = "EC2 Instance type"
    type = string
    default = "t3.micro"
}

variable "rootvolsize" {
    description = "Volumen size of root partition"
    type = number
}

variable "rootvoltype" {
    description = "Volumen type of root partition"
    type = string
    default = "gp2"
}

variable "addpubip" {
    description = "Control public ip association"
    type = bool
    default = false
}

variable "vpcid" {
    description = "id of vps created"
    type = string
}

variable "subnetc" {
    description = "subnet private az1"
    type = string
}

variable "subnetd" {
    description = "subnet private az2"
    type = string
}

variable environment {
    description = "Environment of the solution"
    type = string
}
