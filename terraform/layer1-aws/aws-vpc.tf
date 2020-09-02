resource "null_resource" "subnets" {
  count = var.az_count

  triggers = {
    private_subnets     = cidrsubnet(var.cidr, 8, count.index)
    public_subnets      = cidrsubnet(var.cidr, 8, count.index + 10)
    database_subnets    = cidrsubnet(var.cidr, 8, count.index + 20)
    elasticache_subnets = cidrsubnet(var.cidr, 8, count.index + 30)
    azs                 = data.aws_availability_zones.available.names[count.index]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = var.cidr

  azs                 = null_resource.subnets[*].triggers.azs
  private_subnets     = null_resource.subnets[*].triggers.private_subnets
  public_subnets      = null_resource.subnets[*].triggers.public_subnets
  database_subnets    = null_resource.subnets[*].triggers.database_subnets
  elasticache_subnets = null_resource.subnets[*].triggers.elasticache_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                  = "${local.name}"
    Environment                           = local.env
    "kubernetes.io/cluster/${local.name}" = "shared"

  }

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
}
