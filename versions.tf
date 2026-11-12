terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket       = "lori-csk-w10-tfstate-a"
    key          = "infra-code/terraform.tfstate"
    region       = "eu-central-1" // "us-west-1"
    use_lockfile = true
  }
}