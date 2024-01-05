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
settings:
  clusterName: ${local.eks_cluster_id}
  clusterEndpoint: ${local.eks_cluster_endpoint}
  interruptionQueue: ${module.karpenter[0].queue_name}

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${module.karpenter[0].irsa_arn}

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

module "karpenter" {
  count = local.karpenter.enabled ? 1 : 0

  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.21.0"

  cluster_name = local.eks_cluster_id

  policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  irsa_oidc_provider_arn          = local.eks_oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  create_iam_role                            = false
  enable_karpenter_instance_profile_creation = true
  iam_role_arn                               = var.node_group_default_iam_role_arn
}

module "karpenter_namespace" {
  count = local.karpenter.enabled ? 1 : 0

  source = "../modules/eks-kubernetes-namespace"
  name   = local.karpenter.namespace
}

resource "kubectl_manifest" "karpenter_ec2nodeclass_private" {
  count = local.karpenter.enabled ? 1 : 0

  yaml_body = <<EOF
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: private
  namespace: karpenter
spec:
  amiFamily: AL2 # Amazon Linux 2
  role: ${var.node_group_default_iam_role_name} # replace with your cluster name NODE ROLE ID from the aws-base
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "private"
        Name: "${local.name}-private"
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${local.name}
  tags:
    karpenter.sh/discovery: ${local.name}
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 100Gi
        volumeType: gp3
EOF

  depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "karpenter_ec2nodeclass_public" {
  count = local.karpenter.enabled ? 1 : 0

  yaml_body = <<EOF
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: public
  namespace: karpenter
spec:
  amiFamily: AL2 # Amazon Linux 2
  role: ${var.node_group_default_iam_role_name} # replace with your cluster name NODE ROLE ID from the aws-base
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "public"
        Name: "${local.name}-public"
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${local.eks_cluster_id}
  tags:
    karpenter.sh/discovery: ${local.eks_cluster_id}
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 100Gi
        volumeType: gp3
EOF

  depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "karpenter_nodepool_default" {
  count = local.karpenter.enabled ? 1 : 0

  yaml_body = <<EOF
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: default
  namespace: karpenter
spec:
  template:
    metadata:
      labels:
        nodegroup: default

    spec:
      # References the Cloud Provider's NodeClass resource, see your cloud provider specific documentation
      nodeClassRef:
        name: private

      requirements:
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["t", "m", "c"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["2", "4", "8"]
        - key: "karpenter.k8s.aws/instance-hypervisor"
          operator: In
          values: ["nitro"]
        - key: "karpenter.k8s.aws/instance-generation"
          operator: Gt
          values: ["3"]
        - key: "kubernetes.io/arch"
          operator: In
          values: ["amd64"]
        - key: "karpenter.sh/capacity-type"
          operator: In
          values: ["spot", "on-demand"]

      # Karpenter provides the ability to specify a few additional Kubelet args.
      # These are all optional and provide support for additional customization and use cases.
      kubelet:
        systemReserved:
          cpu: 100m
          memory: 100Mi
          ephemeral-storage: 1Gi
        kubeReserved:
          cpu: 200m
          memory: 100Mi
          ephemeral-storage: 3Gi
        evictionMaxPodGracePeriod: 60
        imageGCHighThresholdPercent: 85
        imageGCLowThresholdPercent: 80
        cpuCFSQuota: true

  disruption:
    consolidationPolicy: WhenUnderutilized
    expireAfter: 720h

  limits:
    cpu: "1000"
    memory: 1000Gi

EOF

  depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "karpenter_nodepool_ci" {
  count = local.karpenter.enabled ? 1 : 0

  yaml_body = <<EOF
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: ci
  namespace: karpenter
spec:
  template:
    metadata:
      labels:
        nodegroup: ci

    spec:
      nodeClassRef:
        name: public

      taints:
        - key: nodegroup
          value: ci
          effect: NoSchedule

      requirements:
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["t", "m", "c"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["4", "8"]
        - key: "karpenter.k8s.aws/instance-hypervisor"
          operator: In
          values: ["nitro"]
        - key: "karpenter.k8s.aws/instance-generation"
          operator: Gt
          values: ["3"]
        - key: "kubernetes.io/arch"
          operator: In
          values: ["amd64"]
        - key: "karpenter.sh/capacity-type"
          operator: In
          values: ["spot"]

      kubelet:
        systemReserved:
          cpu: 100m
          memory: 100Mi
          ephemeral-storage: 1Gi
        kubeReserved:
          cpu: 200m
          memory: 100Mi
          ephemeral-storage: 3Gi
        evictionMaxPodGracePeriod: 60
        imageGCHighThresholdPercent: 85
        imageGCLowThresholdPercent: 80
        cpuCFSQuota: true

  disruption:
    consolidationPolicy: WhenUnderutilized
    expireAfter: 720h

  limits:
    cpu: "1000"
    memory: 1000Gi

EOF

  depends_on = [helm_release.karpenter]
}

resource "helm_release" "karpenter" {
  count = local.karpenter.enabled ? 1 : 0

  name                = local.karpenter.name
  chart               = local.karpenter.chart
  repository          = local.karpenter.repository
  version             = local.karpenter.chart_version
  namespace           = module.karpenter_namespace[count.index].name
  max_history         = 3
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password

  values = [
    local.karpenter_values
  ]
}
