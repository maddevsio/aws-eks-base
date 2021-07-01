module "aws_iam_alb_ingress_controller" {
  source            = "../aws-iam-alb-ingress-controller"
  name              = var.name
  region            = var.region
  oidc_provider_arn = var.oidc_provider_arn
}

resource "helm_release" "alb_ingress_controller" {
  name        = var.aws-load-balancer-controller
  chart       = var.chart_name
  repository  = var.repository
  version     = var.chart_version
  namespace   = var.namespace
  create_namespace = true
  max_history = var.max_history
  values = [
    templatefile("${path.module}/templates/alb-ingress-controller-values.yaml",
      {
        role_arn     = module.aws_iam_alb_ingress_controller.role_arn,
        region       = var.region,
        cluster_name = var.eks_cluster_id,
        vpc_id       = var.vpc_id,
        image_tag    = var.alb_ingress_image_tag,
    })
  ]
}
