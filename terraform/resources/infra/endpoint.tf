module "vpc_endpoint" {
  source = "../../modules/vpc-endpoints/"
  depends_on = [ module.endpoint_sg ]
  vpc_id = module.vpc.vpc_id
  security_group_ids = [module.endpoint_sg.security_group_id]
  endpoints = {
    ssm = {
      service = "ssm"
      # private_dns_enabled = true
      subnet_ids = module.vpc.private_subnets
      tags                = { Name = "ssm-vpc-endpoint" }

    },
    ssmmessages = {
      # interface endpoint
      service             = "ssmmessages"
      # private_dns_enabled = true
      subnet_ids = module.vpc.private_subnets
      tags                = { Name = "ssmmessages-vpc-endpoint" }
    },
    ec2messages = {
      service         = "ec2messages"      
      # private_dns_enabled = true
      subnet_ids = module.vpc.private_subnets
      tags            = { Name = "ec2messages-vpc-endpoint" }
    }
  }
}


module "endpoint_sg" {
  source = "../../modules/security_group/v1"
   name = "vpc-endpoint-sg"
  description = "security group for vpc endpoint. allow only from vpc cidr"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [
       { 
      description     = "Allow All Traffic from VPC"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      security_groups = []

      cidr_blocks     = [var.vpc_cidr]
    }
  ]
  egress_rules = [
    {
      description     = "Allow Traffic"
      from_port       = 0
      to_port         = 0
      protocol        = "ALL"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}