terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = ">= 4.67.0"
    }
  }

  # required_version = ">= 1.4.2"

  backend "s3" {
      # Replace this with your bucket name!
      bucket                 = "kurt-eks-test" 
      key                    = "terraform-states/kurt-eks-test/workload/terraform.tfstate"
      region                 = "ap-southeast-1" 
      skip_region_validation = true


      # Replace this with your DynamoDB table name!
      dynamodb_table = "kurt-eks-test" #"<Your Dynamo DB>"
      encrypt        = true
  }

}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket = "kurt-eks-test" 
    key    = "terraform-states/kurt-eks-test/infra/terraform.tfstate"
    region = var.region #"<Your Region>"

  }
}


provider "aws" {
  region = var.region
  skip_region_validation = true

  default_tags {
    tags = local.tags
  }
}

locals {
  vpc_id = data.terraform_remote_state.infrastructure.outputs.vpc_id
  private_subnets = data.terraform_remote_state.infrastructure.outputs.private_subnets
  public_subnets = data.terraform_remote_state.infrastructure.outputs.public_subnets
}
