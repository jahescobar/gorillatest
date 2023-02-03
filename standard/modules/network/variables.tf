variable cidr_vpc {
    description = "cidr for vpc"
    type = string
    default = "10.1.0.0/16"
}

variable cidr_subnet1 {
    description = "cidr for public subnet1"
    type = string
    default = "10.1.1.0/24"
}
variable cidr_subnet2 {
    description = "cidr for public subnet2"
    type = string
    default = "10.1.2.0/24"
}

variable cidr_subnet3 {
    description = "cidr for private subnet1"
    type = string
    default = "10.1.3.0/24"
}
variable cidr_subnet4 {
    description = "cidr for private subnet2"
    type = string
    default = "10.1.4.0/24"
}

variable environment {
    description = "Environment of the solution"
    type = string
}

variable ec2sgid {
    description = "Security group id for ssm endpoints"
    type = string
}