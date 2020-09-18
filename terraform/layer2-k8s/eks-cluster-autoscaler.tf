module "aws_iam_autoscaler" {
  source = "../modules/aws-iam-autoscaler"

  name              = local.name
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  eks_cluster_id    = local.eks_cluster_id
}

data "template_file" "cluster_autoscaler" {
  template = file("${path.module}/templates/cluster-autoscaler-values.yaml")

  vars = {
    role_arn     = module.aws_iam_autoscaler.role_arn
    region       = local.region
    cluster_name = local.eks_cluster_id
  }
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  chart      = "cluster-autoscaler"
  repository = local.helm_repo_cluster_autoscaler
  version    = var.cluster_autoscaler_version
  namespace  = kubernetes_namespace.sys.id

  values = [
    "${data.template_file.cluster_autoscaler.rendered}",
  ]
}
