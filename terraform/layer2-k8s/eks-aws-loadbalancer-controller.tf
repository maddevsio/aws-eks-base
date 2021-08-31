#tfsec:ignore:aws-iam-no-policy-wildcards
module "eks_alb_ingress" {
  source = "../modules/eks-aws-loadbalancer-controller"
  count  = var.aws_loadbalancer_controller_enable ? 1 : 0

  name              = local.name
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  eks_cluster_id    = local.eks_cluster_id
  vpc_id            = local.vpc_id
  namespace         = module.ing_namespace.name
}
