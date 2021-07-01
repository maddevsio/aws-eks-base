module "eks_alb_ingress" {
  source            = "./modules/eks-alb-ingress"
  count             = var.eks_alb-ingress ? 1 : 0
  name              = local.name
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  eks_cluster_id    = local.eks_cluster_id
  vpc_id            = local.vpc_id
  namespace         = kubernetes_namespace.ing.id
}
