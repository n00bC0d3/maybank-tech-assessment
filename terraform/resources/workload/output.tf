output "asg_sg" {
  value = module.ec2_rds_sg.security_group_id
}

output "ec2public_sg" {
  value = module.ec2pub_sg.security_group_id
}