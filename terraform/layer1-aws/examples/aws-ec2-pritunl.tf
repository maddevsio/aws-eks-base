module "pritunl" {
  source = "../modules/aws-ec2-pritunl"

  environment    = local.env
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  ingress_with_cidr_blocks = [
    {
      protocol    = "6"
      from_port   = 443
      to_port     = 443
      cidr_blocks = "127.0.0.1/32" # IP address that will have access to the web console
    },
    {
      protocol    = "17"
      from_port   = 19739 # this is a port that we will set in pritunl server configuration (after installation)
      to_port     = 19739
      cidr_blocks = "0.0.0.0/0"
    },
    {
      protocol    = "6"
      from_port   = 80
      to_port     = 80
      cidr_blocks = "127.0.0.1/32" # IP address that will have access to the web console
    },
  ]
}
