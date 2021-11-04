locals {
  teamcity = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "teamcity")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "teamcity")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "teamcity")], "version", null)
  }
  teamcity_domain_name = "teamcity-${local.domain_suffix}"
}

module "eks_rbac_teamcity" {
  source = "../modules/eks-rbac-ci"

  name      = "${local.name}-teamcity"
  role_arn  = module.aws_iam_teamcity.role_arn
  namespace = module.ci_namespace.name
}

data "template_file" "teamcity_agent" {
  template = file("${path.module}/templates/teamcity-agent-pod-template.yaml")

  vars = {
    service_account_name = module.eks_rbac_teamcity.service_account_name
  }
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
  chart           = local.teamcity.chart
  repository      = local.teamcity.repository
  version         = local.teamcity.chart_version
  namespace       = module.ci_namespace.name
  wait            = false
  cleanup_on_fail = true
  max_history     = var.helm_release_history_size

  values = [
    data.template_file.teamcity.rendered
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

module "aws_iam_teamcity" {
  source = "../modules/aws-iam-eks-trusted"

  name              = "${local.name}-teamcity"
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:*",
        ],
        "Resource" : "*"
      }
    ]
  })
}

output "teamcity_domain_name" {
  value       = local.teamcity_domain_name
  description = "Teamcity server"
}

output "teamcity_service_account_name" {
  value = module.eks_rbac_teamcity.service_account_name
}

output "teamcity_agent_pod_template" {
  value = data.template_file.teamcity_agent.rendered
}

output "teamcity_kubernetes_api_url" {
  value = data.aws_eks_cluster.main.endpoint
}
