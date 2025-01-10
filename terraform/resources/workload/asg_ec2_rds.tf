module "ec2_rds_sg" {
  source = "../../modules/security_group/v1"

  name        = "ec2rds-sg-iac"
  description = "Autoscaling group security group for EC2 RDS"
  vpc_id      = local.vpc_id

  ingress_rules = [
    {
      description     = "Allow All Traffic from NLB"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      security_groups = [module.nlb_public_sg.security_group_id]

      cidr_blocks     = []
    },
    {
      description     = "Allow All Traffic from bastion host"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      security_groups = [module.ec2pub_sg.security_group_id]

      cidr_blocks     = []
    }
  ]
  egress_rules = [
    {
      description     = "Allow Traffic to All"
      from_port       = 0
      to_port         = 0
      protocol        = "ALL"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = local.tags
}




module "autoscaling_ec2_rds" {
  source = "../../modules/autoscaling/v2"

  name = var.ec2_asg_name

  image_id = "ami-06650ca7ed78ff6fa" # ubuntu 24.04 sg 

  instance_type = "t2.micro"
  key_name      = var.keypair


  security_groups = [module.ec2_rds_sg.security_group_id]
  # user_data       = base64encode(each.value.user_data)

  ignore_desired_capacity_changes = false

  create_iam_instance_profile = true
  iam_instance_profile_name   = "EC2SSM"

  iam_role_name        = "${var.ec2_asg_name}-instance-role"

  iam_role_description = "Instance role for ${var.ec2_asg_name}"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEC2RoleforSSM          = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  }



  # block_device_mappings = [{
  #   device_name = "/dev/sda1"
  #   ebs = {
  #     encrypted = true
  #     kms_key_id = "arn:aws:kms:ap-southeast-3:672275484883:key/d1b37411-f851-4a22-bc9f-d99a479d7156"
  #   }
  # }]

  vpc_zone_identifier = [local.private_subnets[1]]
  health_check_type   = "EC2"
  min_size            = 1
  max_size            = 2 
  desired_capacity    = 1

  # Required for  managed_termination_protection = "ENABLED"
  # protect_from_scale_in = false

  target_group_arns = [module.nlb_public.target_group_arns[0]]

  user_data =base64encode(<<-EOT
  #!/bin/bash
  sudo apt update -y
  sudo apt install nginx -y
  EOT
  )
}
