locals {
  alb_ingress_controller = templatefile("${path.module}/templates/alb-ingress-controller-values.yaml",
    {
      role_arn      = module.aws_iam_aws_loadbalancer_controller.role_arn,
      region        = var.region,
      cluster_name  = var.eks_cluster_id,
      vpc_id        = var.vpc_id,
      image_tag     = var.image_tag,
      replica_count = var.replica_count,
  })
}
