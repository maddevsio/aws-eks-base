module "kube_prometheus_stack" {
  source = "../modules/eks-kube-prometheus-stack"
  count  = var.kube_prometheus_stack_enable ? 1 : 0

  name                  = local.name
  region                = local.region
  domain_name           = local.domain_suffix
  kubernetes_namespace  = kubernetes_namespace.monitoring.id
  eks_oidc_provider_arn = local.eks_oidc_provider_arn
  ip_whitelist          = local.ip_whitelist
}


