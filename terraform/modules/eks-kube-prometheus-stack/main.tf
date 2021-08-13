resource "random_string" "grafana_password" {
  length  = 20
  special = true
}

module "aws_iam_grafana" {
  source = "../aws-iam-grafana"

  name              = var.name
  region            = var.region
  oidc_provider_arn = var.eks_oidc_provider_arn
}

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  chart            = "kube-prometheus-stack"
  repository       = var.helm_repo_prometheus_community
  namespace        = local.kubernetes_namespace
  create_namespace = local.helm_release_create_namespace
  version          = var.kube_prometheus_stack_version
  wait             = var.helm_release_wait
  max_history      = var.helm_release_history_size

  values = [
    local.kube_prometheus_stack_template
  ]

}

