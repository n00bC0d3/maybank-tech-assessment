

module "ec2pub_sg" {
  source = "../../modules/security_group/v1"

  name        = "ec2pub-sg-iac"
  description = "security group for ec2 public subnet"
  vpc_id      = local.vpc_id

  ingress_rules = [
    {
      description     = "Allow All Traffic"
      from_port       = 0
      to_port         = 0
      protocol        = -1
      security_groups = []

      cidr_blocks     = ["0.0.0.0/0"]
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
}


module "ec2_bastion" {
  source = "../../modules/ec2/v1"

  name = "ec2-bastion-iac"
  
  ami = "ami-06650ca7ed78ff6fa" # ubuntu 24.04 sg 
  # ami = "ami-0995922d49dc9a17d" # AL 2003

  instance_type = "t2.micro"    
  key_name = var.keypair

  vpc_security_group_ids = [module.ec2pub_sg.security_group_id]
  associate_public_ip_address = true

  # existing instance have no IAM role
  # create_iam_instance_profile = true
  iam_role_name        = "ec2-bastion-instance-role"

  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEC2RoleforSSM          = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  }

  subnet_id = local.public_subnets[0]

}
