provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = var.environment
      Owner       = var.owner
    }
  }
}