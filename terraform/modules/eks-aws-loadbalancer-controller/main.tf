module "aws_iam_aws_loadbalancer_controller" {
  source            = "../aws-iam-aws-loadbalancer-controller"
  name              = var.name
  region            = var.region
  oidc_provider_arn = var.oidc_provider_arn
}

resource "helm_release" "aws_loadbalancer_controller" {
  name             = var.release_name
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
