locals {
  cidr_subnets     = [for cidr_block in cidrsubnets(var.cidr, 2, 2, 2, 2) : cidrsubnets(cidr_block, 4, 4, 4, 4)]
  private_subnets  = chunklist(local.cidr_subnets[0], var.az_count)[0]
  public_subnets   = chunklist(local.cidr_subnets[1], var.az_count)[0]
  database_subnets = chunklist(local.cidr_subnets[2], var.az_count)[0]
  intra_subnets    = chunklist(local.cidr_subnets[3], var.az_count)[0]
  azs              = data.aws_availability_zones.available.names
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.12.0"

  name = local.name
  cidr = var.cidr

  azs              = local.azs
  private_subnets  = local.private_subnets
  public_subnets   = local.public_subnets
  database_subnets = local.database_subnets
  intra_subnets    = local.intra_subnets

  single_nat_gateway   = var.single_nat_gateway
  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  create_database_subnet_group = false

  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  tags = merge(local.tags, {
    "kubernetes.io/cluster/${local.name}" = "shared"
  })

  private_subnet_tags = {
    Name                              = "${local.name}-private"
    destination                       = "private"
    "kubernetes.io/role/internal-elb" = "1"
  }

  private_route_table_tags = {
    Name        = "${local.name}-private"
    destination = "private"
  }

  public_subnet_tags = {
    Name                     = "${local.name}-public"
    destination              = "public"
    "kubernetes.io/role/elb" = "1"
  }

  public_route_table_tags = {
    Name        = "${local.name}-public"
    destination = "public"
  }

  database_subnet_tags = {
    Name        = "${local.name}-database"
    destination = "database"
  }

  database_route_table_tags = {
    Name        = "${local.name}-database"
    destination = "database"
  }

  intra_subnet_tags = {
    Name        = "${local.name}-intra"
    destination = "intra"
  }

  intra_route_table_tags = {
    Name        = "${local.name}-intra"
    destination = "intra"
  }
}
