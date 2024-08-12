locals {
  eks_cluster_endpoint = data.aws_eks_cluster.main.endpoint
  karpenter = {
    name          = try(var.helm.release_name, "karpenter")
    enabled       = true
    chart         = try(var.helm.chart_name, "karpenter")
    repository    = try(var.helm.repository, "oci://public.ecr.aws/karpenter")
    chart_version = try(var.helm.chart_version, "0.37.0")
    namespace     = try(var.helm.namespace, "karpenter")
  }

  karpenter_values = <<VALUES
settings:
  clusterName: ${var.eks_cluster_id}
  clusterEndpoint: ${local.eks_cluster_endpoint}
  interruptionQueue: ${module.this[0].queue_name}

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${module.this[0].iam_role_arn}

controller:
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      memory: 512Mi

VALUES
}

data "aws_ecrpublic_authorization_token" "token" {}

module "this" {
  count = local.karpenter.enabled ? 1 : 0

  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.17.2"

  cluster_name = var.eks_cluster_id

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  enable_irsa            = true
  irsa_oidc_provider_arn = var.eks_oidc_provider_arn
  enable_pod_identity    = false

  create_node_iam_role = false
  node_iam_role_arn    = var.node_group_default_iam_role_arn
  # Since the node group role will already have an access entry
  create_access_entry = false

}

module "namespace" {
  count = local.karpenter.enabled ? 1 : 0

  source = "../eks-kubernetes-namespace"
  name   = local.karpenter.namespace
}

resource "kubectl_manifest" "ec2nodeclass_private" {
  count = local.karpenter.enabled ? 1 : 0

  yaml_body = <<EOF
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: private
  namespace: ${local.karpenter.namespace}
spec:
  amiFamily: AL2023 # Amazon Linux 2023
  role: ${var.node_group_default_iam_role_name} # replace with your cluster name NODE ROLE ID from the aws-eks
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "private"
        Name: "${var.name}-private"
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${var.name}
  tags:
    karpenter.sh/discovery: ${var.name}
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 100Gi
        volumeType: gp3
EOF

  depends_on = [helm_release.this]
}

resource "kubectl_manifest" "ec2nodeclass_public" {
  count = local.karpenter.enabled ? 1 : 0

  yaml_body = <<EOF
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: public
  namespace: ${local.karpenter.namespace}
spec:
  amiFamily: AL2023 # Amazon Linux 2023
  role: ${var.node_group_default_iam_role_name} # replace with your cluster name NODE ROLE ID from the aws-base
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "public"
        Name: "${var.name}-public"
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${var.eks_cluster_id}
  tags:
    karpenter.sh/discovery: ${var.eks_cluster_id}
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 100Gi
        volumeType: gp3
EOF

  depends_on = [helm_release.this]
}

resource "kubectl_manifest" "nodepool" {
  for_each = { for nodepool in var.nodepools : nodepool.metadata.name => nodepool if local.karpenter.enabled }

  yaml_body          = yamlencode(each.value)
  override_namespace = local.karpenter.namespace

  depends_on = [kubectl_manifest.ec2nodeclass_private, kubectl_manifest.ec2nodeclass_public]
}

resource "helm_release" "this" {
  count = local.karpenter.enabled ? 1 : 0

  name                = local.karpenter.name
  chart               = local.karpenter.chart
  repository          = local.karpenter.repository
  version             = local.karpenter.chart_version
  namespace           = module.namespace[count.index].name
  max_history         = 3
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password

  values = [
    local.karpenter_values
  ]
}
