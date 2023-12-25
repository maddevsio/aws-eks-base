locals {
  karpenter = {
    name          = "karpenter"                      #local.helm_releases[index(local.helm_releases.*.id, "karpenter")].id
    enabled       = true                             #local.helm_releases[index(local.helm_releases.*.id, "karpenter")].enabled
    chart         = "karpenter"                      #local.helm_releases[index(local.helm_releases.*.id, "karpenter")].chart
    repository    = "oci://public.ecr.aws/karpenter" #local.helm_releases[index(local.helm_releases.*.id, "karpenter")].repository
    chart_version = "v0.33.0"                        #local.helm_releases[index(local.helm_releases.*.id, "karpenter")].chart_version
    namespace     = "karpenter"                      #local.helm_releases[index(local.helm_releases.*.id, "karpenter")].namespace
  }

  karpenter_values = <<VALUES
settings:
  clusterName: ${var.eks_cluster_id}
  clusterEndpoint: ${var.eks_cluster_endpoint}
  interruptionQueue: ${module.karpenter.queue_name}

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${module.karpenter.irsa_arn}

controller:
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      memory: 512Mi

VALUES
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.21.0"

  cluster_name = var.eks_cluster_id

  policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  irsa_oidc_provider_arn          = var.eks_oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  create_iam_role                            = false
  enable_karpenter_instance_profile_creation = true
  iam_role_arn                               = var.node_group_default_iam_role_arn
}

module "namespace" {
  source = "../eks-kubernetes-namespace"
  name   = var.k8s_namespace
}

resource "kubectl_manifest" "this" {
  for_each = var.kubectl_manifests

  yaml_body = each.value

  depends_on = [helm_release.this]
}

resource "helm_release" "this" {
  name                = local.karpenter.name
  chart               = local.karpenter.chart
  repository          = local.karpenter.repository
  version             = local.karpenter.chart_version
  namespace           = module.namespace.name
  max_history         = 3
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password

  values = [
    local.karpenter_values,
    var.extra_helm_values
  ]
}

data "aws_ecrpublic_authorization_token" "token" {}
