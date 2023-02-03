variable region {
    description = "Aws Region to work on"
    type = string
    default = "us-east-1"
}

variable environment {
    description = "Environment of the solution"
    type = string
    default = "Prod"
}

variable owner {
    description = "Owner of the solution"
    type = string
    default = "jahescobar"
}

variable "application" {
    description = "Application name"
    type = string
}
