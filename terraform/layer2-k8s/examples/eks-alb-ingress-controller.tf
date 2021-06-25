module "eks_alb-ingress" {
  source             = "../modules/eks_alb-ingress"
  name               = local.name
  region             = local.region
  oidc_provider_arn  = local.eks_oidc_provider_arn
  repository         = local.helm_repo_incubator
  chart_version      = var.alb_ingress_chart_version
  namespace          = kubernetes_namespace.ing.id
  max_history        = var.helm_release_history_size
  values = [
   templatefile("${path.module}/templates/alb-ingress-controller-values.yaml",
   {
   role_arn          = module.aws_iam_alb_ingress_controller.role_arn,
   region            = local.region,
   cluster_name      = local.eks_cluster_id,
   vpc_id            = local.vpc_id,
   image_tag         = var.alb_ingress_image_tag,
     })
  ]
}
