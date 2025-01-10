resource "aws_db_subnet_group" "mariadb-subnet" {
  name       = "mariadb-subnet-group"
  subnet_ids = local.db_subnets  

  tags = {
    Name = "mariadb-db-subnet-group"
  }
}

# resource "aws_db_subnet_group" "mariadb-replica-subnet" {
#   name       = "mariadb-subnet-group2"
#   subnet_ids = local.db_subnets  

#   tags = {
#     Name = "mariadb-db-subnet-group2"
#   }
# }

module "rds_sg" {
  source = "../../../modules/security_group/v1"

  name = "rds-mariadb-sg"
  description = "security group for rds maria db"
  vpc_id = local.vpc_id

  ingress_rules = [ 
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      security_groups = [local.ec2_asg_secgroup]
      cidr_blocks = [] 
      description = "from server"
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      security_groups = [local.ec2bastion_secgroup]
      cidr_blocks = [] 
      description = "from bastion"
    }
    
  ]

  egress_rules = [ 
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "egress all"
      security_groups = []
    }
  ]

  tags = {
    Name = "rds-security-group"
  }
}

resource "aws_db_instance" "primary" {
  identifier              = "mariadb-master"
  allocated_storage       = 20
  engine                  = "mariadb"
  engine_version          = "10.6"
  instance_class          = "db.t4g.micro"  # Free-tier eligible size
  db_name                 = "myMariaDB"
  username                = "admin"
  password                = "yourpassword"  # Replace with a secure password
  # parameter_group_name    = 
  multi_az                    = false
  availability_zone = data.aws_availability_zones.available.names[1]
  db_subnet_group_name    = aws_db_subnet_group.mariadb-subnet.name
  
  vpc_security_group_ids  = [module.rds_sg.security_group_id]
  backup_retention_period = 7
  skip_final_snapshot     = true

  tags = {
    Name = "mariadb-primary"
  }
}

resource "aws_db_instance" "read_replica" {
  depends_on = [ aws_db_instance.primary ]
  identifier              = "mariadb-read-replica"
  engine                  = "mariadb"
  instance_class          = "db.t4g.micro"  # Free-tier eligible size
  db_subnet_group_name    = aws_db_subnet_group.mariadb-subnet.name
  replicate_source_db = aws_db_instance.primary.arn
  vpc_security_group_ids  = [module.rds_sg.security_group_id]
  availability_zone       =  data.aws_availability_zones.available.names[0]
  skip_final_snapshot = true
  tags = {
    Name = "mariadb-read-replica"
  }
}
