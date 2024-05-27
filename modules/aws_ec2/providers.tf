provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "usw2"
  region = "us-west-2"
}

terraform {
  required_version = ">= 1.3.7"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 4.51.0"
      version = "~> 5.43.0"
    }
  }
}