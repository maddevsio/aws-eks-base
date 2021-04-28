module "aws_iam_alb_ingress_controller" {
  source = "../modules/aws-iam-alb-ingress-controller"

  name              = local.name
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
}

data "template_file" "alb_ingress_controller" {
  template = file("${path.module}/templates/alb-ingress-controller-values.yaml")

  vars = {
    role_arn     = module.aws_iam_alb_ingress_controller.role_arn
    region       = local.region
    cluster_name = local.eks_cluster_id
    vpc_id       = local.vpc_id
    image_tag    = var.alb_ingress_image_tag
  }
}

resource "helm_release" "alb_ingress_controller" {
  name        = "aws-alb-ingress-controller"
  chart       = "aws-alb-ingress-controller"
  repository  = local.helm_repo_incubator
  version     = var.alb_ingress_chart_version
  namespace   = kubernetes_namespace.ing.id
  max_history = var.helm_release_history_size

  values = [
    data.template_file.alb_ingress_controller.rendered
  ]
}
