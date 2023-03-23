locals {
  karpenter = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "karpenter")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "karpenter")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "karpenter")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "karpenter")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "karpenter")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "karpenter")].namespace
  }

  karpenter_values = <<VALUES
serviceMonitor:
  enabled: true

settings:
  aws:
    clusterName: ${local.eks_cluster_id}
    clusterEndpoint: ${local.eks_cluster_endpoint}
    defaultInstanceProfile: ${var.node_group_addons_iam_instance_profile_id}
    interruptionQueueName: ${local.karpenter.enabled ? module.karpenter[0].queue_name : ""}

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${local.karpenter.enabled ? module.karpenter[0].irsa_arn : ""}

affinity:
  nodeAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 50
      preference:
        matchExpressions:
        - key: eks.amazonaws.com/capacityType
          operator: In
          values:
            - ondemand
    - weight: 1
      preference:
        matchExpressions:
        - key: karpenter.sh/capacity-type
          operator: In
          values:
          - on-demand
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - topologyKey: "kubernetes.io/hostname"

VALUES
}

module "karpenter" {
  count   = local.karpenter.enabled ? 1 : 0
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "18.31.0"

  cluster_name = local.eks_cluster_id

  irsa_oidc_provider_arn          = local.eks_oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  create_iam_role = false
  create_instance_profile = false
  iam_role_arn    = var.node_group_addons_iam_role_arn
}

module "karpenter_namespace" {
  count = local.karpenter.enabled ? 1 : 0

  source = "../modules/eks-kubernetes-namespace"
  name   = local.karpenter.namespace
}


resource "helm_release" "karpenter" {
  count = local.karpenter.enabled ? 1 : 0

  name                = local.karpenter.name
  chart               = local.karpenter.chart
  repository          = local.karpenter.repository
  version             = local.karpenter.chart_version
  namespace           = module.karpenter_namespace[count.index].name
  max_history         = 10
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password

  values = [
    local.karpenter_values
  ]

  depends_on = [kubectl_manifest.kube_prometheus_stack_operator_crds]
}

resource "kubectl_manifest" "karpenter_provisioner_default" {
  count = local.karpenter.enabled ? 1 : 0

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1alpha5
    kind: Provisioner
    metadata:
      name: default
    spec:
      labels:
        karpenter_mixed: "true"
      requirements:
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["t", "m"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot", "on-demand"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["2", "4"]
        - key: karpenter.k8s.aws/instance-size
          operator: NotIn
          values: [nano, micro, small]
      limits:
        resources:
          cpu: 1000
      providerRef:
        name: private-subnet
      ttlSecondsAfterEmpty: 30
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_provisioner_ci" {
  count = local.karpenter.enabled ? 1 : 0

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1alpha5
    kind: Provisioner
    metadata:
      name: ci
    spec:
      labels:
        karpenter_ci: "true"
      taints:
        - key: ci
          value: "true"
          effect: NoSchedule
      requirements:
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["t", "m"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["1", "2", "4"]
      limits:
        resources:
          cpu: 1000
      providerRef:
        name: public-subnet
      ttlSecondsAfterEmpty: 30
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_template_public_subnet" {
  count = local.karpenter.enabled ? 1 : 0
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: public-subnet
    spec:
      subnetSelector:
        karpenter.sh/discovery: "public"
      securityGroupSelector:
        karpenter.sh/discovery: ${local.eks_cluster_id}
      tags:
        karpenter.sh/discovery: ${local.eks_cluster_id}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_template_private_subnet" {
  count = local.karpenter.enabled ? 1 : 0
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: private-subnet
    spec:
      subnetSelector:
        karpenter.sh/discovery: "private"
      securityGroupSelector:
        karpenter.sh/discovery: ${local.eks_cluster_id}
      tags:
        karpenter.sh/discovery: ${local.eks_cluster_id}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

data "aws_ecrpublic_authorization_token" "token" {}


