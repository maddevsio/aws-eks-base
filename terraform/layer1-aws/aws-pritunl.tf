#tfsec:ignore:aws-vpc-no-public-egress-sgr tfsec:ignore:aws-vpc-no-public-ingress-sgr
module "pritunl" {
  count = var.pritunl_vpn_server_enable ? 1 : 0

  source          = "../modules/aws-pritunl"
  environment     = var.env
  vpc_id          = var.vpc_id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  ingress_with_cidr_blocks = [
    {
      protocol    = "6"
      from_port   = 443
      to_port     = 443
      cidr_blocks = var.pritunl_vpn_access_cidr_blocks
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
      cidr_blocks = var.pritunl_vpn_access_cidr_blocks
    },
  ]
}
