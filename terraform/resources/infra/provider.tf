terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67.0"
    }
  }

  required_version = ">= 1.4.2"

  backend "s3" {
      bucket                 = "kurt-eks-test" 
      key                    = "terraform-states/kurt-eks-test/infra/terraform.tfstate"
      region                 = "ap-southeast-1" 
      skip_region_validation = true


      # Replace this with your DynamoDB table name!
      dynamodb_table = "kurt-eks-test" 
      encrypt        = true
  }

}



provider "aws" {
  region = var.region
  skip_region_validation = true

  default_tags {
    tags = local.tags
  }
}
