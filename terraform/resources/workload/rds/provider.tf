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
      key                    = "terraform-states/kurt-eks-test/workload/rds/terraform.tfstate"
      region                 = "ap-southeast-1" 
      skip_region_validation = true

      dynamodb_table = "kurt-eks-test" 
      encrypt        = true
  }

}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket = "kurt-eks-test" 
    key    = "terraform-states/kurt-eks-test/infra/terraform.tfstate"
    region = var.region 
  }
}

data "terraform_remote_state" "workload" {
  backend = "s3"
  config = {
    bucket = "kurt-eks-test" 
    key    = "terraform-states/kurt-eks-test/workload/terraform.tfstate"
    region = var.region 
  }
}

provider "aws" {
  region = var.region
  skip_region_validation = true


}

data "aws_availability_zones" "available" {}

locals {
  vpc_id = data.terraform_remote_state.infrastructure.outputs.vpc_id
  private_subnets = data.terraform_remote_state.infrastructure.outputs.private_subnets
  public_subnets = data.terraform_remote_state.infrastructure.outputs.public_subnets
  db_subnets =  data.terraform_remote_state.infrastructure.outputs.private_subnets
  ec2_asg_secgroup = data.terraform_remote_state.workload.outputs.asg_sg
  ec2bastion_secgroup = data.terraform_remote_state.workload.outputs.ec2public_sg
}
