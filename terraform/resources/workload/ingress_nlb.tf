module "nlb_public_sg" {
  source = "../../modules/security_group/v1"

  name        = "nlb-public-sg"
  description = "security group for NLB ingress"
  vpc_id      = local.vpc_id

  ingress_rules = [
    {
      description     = "Allow All Traffic from Cloudfront"
      from_port       = 80
      to_port         = 80
      protocol        = "TCP"
      security_groups = []
      prefix_list_ids  = ["pl-31a34658"]
      cidr_blocks     = []
    },
      {
      description     = "Allow All Traffic from internet"
      from_port       = 80
      to_port         = 80
      protocol        = "TCP"
      security_groups = []
      # prefix_list_ids  = ["pl-31a34658"]
      cidr_blocks     = ["0.0.0.0/0"]
    },
    {
      description     = "Allow ping from internet"
      from_port       = -1
      to_port         = -1
      protocol        = "ICMP"
      security_groups = []
      # prefix_list_ids  = ["pl-31a34658"]
      cidr_blocks     = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      description     = "Allow Traffic"
      from_port       = 0
      to_port         = 65535
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]

  tags = local.tags
}


##### Application Load Balancer #####
#####################################
module "nlb_public" {
  source = "../../modules/alb/v2"

  name = "nlb-ingress-iac"

  load_balancer_type = "network"

  internal = false

  security_groups = [module.nlb_public_sg.security_group_id]

  vpc_id = local.vpc_id
  # subnets = [local.private_subnets[1]]
  subnets = local.public_subnets
  # enable_cross_zone_load_balancing = true

  # enable_deletion_protection = true



  # subnet_mapping = [
  #   {
  #     subnet_id            = "subnet-07a7e59a6891c893e",
  #     private_ipv4_address = "10.100.32.99"
  #   },
  #   {
  #     subnet_id            = "subnet-0713bb74c9699bf25",
  #     private_ipv4_address = "10.100.34.99"
  #   },
  #   {
  #     subnet_id            = "subnet-0be21621cf454b9c4",
  #     private_ipv4_address = "10.100.36.99"
  #   }
  # ]


  # DEFAULT and LAST PRIORITY of ROUTE
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      action_type        = "forward"
      target_group_index = 0
    }
  ]

  # https_listeners = [{
  #     port               = 443
  #     protocol           = "HTTPS"
  #     certificate_arn    = module.acm.acm_certificate_arn
  #     target_group_index = 1
  # }]

  # List the Target Group
  target_groups = [
    {
      name             = "nlb-tg-asg-rds-iac"
      backend_port     = 80
      backend_protocol = "tcp"
      target_type      = "instance"
    }
  ]
}
