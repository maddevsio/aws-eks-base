module "ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.8.0"

  name        = var.name
  description = "${var.name} security group"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = var.ingress_with_source_security_group_id

  ingress_with_cidr_blocks = var.ingress_with_cidr_blocks

  egress_with_cidr_blocks = [
    {
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "efs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.8.0"

  name        = "${var.name}-efs"
  description = "${var.name} efs security group"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      protocol                 = "6"
      from_port                = 2049
      to_port                  = 2049
      source_security_group_id = module.ec2_sg.security_group_id
    }
  ]
}
