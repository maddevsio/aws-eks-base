module "aws_iam_alb_ingress_controller" {
  source            = "../aws-iam-alb-ingress-controller"
  name              = var.name
  region            = var.region
  oidc_provider_arn = var.oidc_provider_arn
}

resource "helm_release" "alb_ingress_controller" {
  name             = var.aws-load-balancer-controller
  chart            = var.chart_name
  repository       = var.repository
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  max_history      = var.max_history
  values = [
    local.alb_ingress_controller
  ]
}
