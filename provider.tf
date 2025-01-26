terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.6" # which means any version equal & above
    }
  }
  required_version = ">= 0.13"
}

# Initialize the provider
provider "aws" {
  region = "us-east-1" # Change the region as needed
}