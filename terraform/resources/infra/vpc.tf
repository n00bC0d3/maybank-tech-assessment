locals {
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 3)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  # source  = "terraform-aws-modules/vpc/aws"
  # version = "~> 5.1"
  source = "../../modules/vpc"
  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                   = local.azs
  public_subnets        = local.public_subnets
  private_subnets       = local.private_subnets
  public_subnet_suffix  = "SubnetPublic"
  private_subnet_suffix = "SubnetPrivate"

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = false

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${var.vpc_name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${var.vpc_name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${var.vpc_name}-default" }

  # public_subnet_tags = merge(local.tags, {
  #   "kubernetes.io/role/elb" = "1"
  # })
  # private_subnet_tags = merge(local.tags, {
  #   "karpenter.sh/discovery"          = var.vpc_name
  #   "kubernetes.io/role/internal-elb" = "1"
  # })

  # nat_gateway_tags = var.nat_gateway_tags
  tags = local.tags
}