locals {
  alb_ingress_controller = templatefile("${path.module}/templates/alb-ingress-controller-values.yaml",
    {
      role_arn     = module.aws_iam_alb_ingress_controller.role_arn,
      region       = var.region,
      cluster_name = var.eks_cluster_id,
      vpc_id       = var.vpc_id,
      image_tag    = var.alb_ingress_image_tag,
  })
}

