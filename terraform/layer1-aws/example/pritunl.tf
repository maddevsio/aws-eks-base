module "pritunl" {
  source = "../modules/pritunl"

  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  pritunl_sg_rules = [
    {
      protocol    = "6"
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["8.8.8.8/32"] # the list of IPs that will have access to the web console
    },
    {
      protocol    = "17"
      from_port   = 19739 #this is a port that we will set in pritunl server configuration (after installation)
      to_port     = 19739
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
