module "aws_iam_alb_ingress_controller" {
  source = "../modules/aws-iam-alb-ingress-controller"
  name              = var.name
  region            = var.region
  oidc_provider_arn = var.oidc_provider_arn
}

resource "helm_release" "alb_ingress_controller" {
  name        = var.aws-alb-ingress-controller
  chart       = var.chart_name
  repository  = var.repository
  version     = var.chart_version
  namespace   = var.namespace
  max_history = var.max_history

  values = var.value
}
