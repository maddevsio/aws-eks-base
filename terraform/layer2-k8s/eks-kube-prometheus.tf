module "kube_prometheus_stack" {
  source = "../modules/eks-prometheus-stack"

  name                           = local.name
  region                         = local.region
  domain_suffix                  = local.domain_suffix
  eks_oidc_provider_arn          = local.eks_oidc_provider_arn
  helm_repo_prometheus_community = local.helm_repo_prometheus_community
  kubernetes_namespace           = "monitoring"
  kube_prometheus_stack_version  = var.prometheus_operator_version
  helm_release_history_size      = var.helm_release_history_size
  ip_whitelist                   = local.ip_whitelist

}
