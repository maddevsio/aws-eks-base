locals {
  teamcity_domain_name = "teamcity-${local.domain_suffix}"
}

output "teamcity_domain_name" {
  value       = local.teamcity_domain_name
  description = "Teamcity server"
}

output name {
  value       = ""
  sensitive   = true
  description = "description"
  depends_on  = []
}


module "aws_iam_teamcity" {
  source = "../modules/aws-iam-ci"

  name              = "${local.name}-teamcity"
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  eks_cluster_id    = local.eks_cluster_id
}

module "eks_rbac_teamcity" {
  source = "../modules/eks-rbac-ci"

  name      = "${local.name}-teamcity"
  role_arn  = module.aws_iam_teamcity.role_arn
  namespace = kubernetes_namespace.ci.id
}

data "template_file" "teamcity" {
  template = file("${path.module}/templates/teamcity-values.yaml")

  vars = {
    domain_name          = local.teamcity_domain_name
    storage_class_name   = kubernetes_storage_class.teamcity.id
    service_account_name = module.eks_rbac_teamcity.service_account_name
  }
}

resource "helm_release" "teamcity" {
  name            = "teamcity"
  chart           = "../../helm-charts/teamcity"
  namespace       = kubernetes_namespace.ci.id
  wait            = false
  cleanup_on_fail = true
  values = [
    "${data.template_file.teamcity.rendered}",
  ]
}

resource "kubernetes_storage_class" "teamcity" {
  metadata {
    name = "teamcity"
  }
  storage_provisioner    = "kubernetes.io/aws-ebs"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  parameters = {
    type      = "gp2"
    encrypted = true
    fsType    = "ext4"
  }
}
