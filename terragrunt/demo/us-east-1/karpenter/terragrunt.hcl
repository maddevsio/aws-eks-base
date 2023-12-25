include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "${get_terragrunt_dir()}/../../../../terraform//modules/karpenter"
}

dependencies {
  paths = ["../aws-base"]
}

dependency "aws-base" {
  config_path = "../aws-base"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]

  mock_outputs = {
    eks_cluster_id                   = "maddevs-demo-use1"
    eks_oidc_provider_arn            = "arn:aws:iam::731118884724:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/D55EEBDFE5510B81EEE2381B88888888"
    eks_cluster_endpoint             = "https://D55EEBDFE5510B81EEE2381B88888888.gr7.us-east-1.eks.amazonaws.com"
    node_group_default_iam_role_arn  = "arn:aws:iam::731118884724:role/maddevs-demo-use1-default-202312210752134060000000a"
    node_group_default_iam_role_name = "test"
  }
}

inputs = {
  eks_cluster_id                  = dependency.aws-base.outputs.eks_cluster_id
  eks_oidc_provider_arn           = dependency.aws-base.outputs.eks_oidc_provider_arn
  eks_cluster_endpoint            = dependency.aws-base.outputs.eks_cluster_endpoint
  node_group_default_iam_role_arn = dependency.aws-base.outputs.node_group_default_iam_role_arn
  kubectl_manifests = {
    default_ec2class = <<EOF
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: default
  namespace: karpenter
spec:
  amiFamily: AL2 # Amazon Linux 2
  role: ${dependency.aws-base.outputs.node_group_default_iam_role_name} # replace with your cluster name NODE ROLE ID from the aws-base
  subnetSelectorTerms:
    - tags:
        destination: "private" # replace with your cluster name
        Name: "${dependency.aws-base.outputs.eks_cluster_id}-private"
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${dependency.aws-base.outputs.eks_cluster_id} # replace with your cluster name
  tags:
    karpenter.sh/discovery: ${dependency.aws-base.outputs.eks_cluster_id}
EOF

    default_nodepool = <<EOF
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: default
  namespace: karpenter
spec:
  # Template section that describes how to template out NodeClaim resources that Karpenter will provision
  # Karpenter will consider this template to be the minimum requirements needed to provision a Node using this NodePool
  # It will overlay this NodePool with Pods that need to schedule to further constrain the NodeClaims
  # Karpenter will provision to launch new Nodes for the cluster
  template:
    metadata:
      # Labels are arbitrary key-values that are applied to all nodes
      labels:
        type: default

      # # Annotations are arbitrary key-values that are applied to all nodes
      # annotations:
      #   example.com/owner: "my-team"
    spec:
      # References the Cloud Provider's NodeClass resource, see your cloud provider specific documentation
      nodeClassRef:
        name: default

      # Provisioned nodes will have these taints
      # Taints may prevent pods from scheduling if they are not tolerated by the pod.
      # taints:
      #   - key: example.com/special-taint
      #     effect: NoSchedule

      # Provisioned nodes will have these taints, but pods do not need to tolerate these taints to be provisioned by this
      # NodePool. These taints are expected to be temporary and some other entity (e.g. a DaemonSet) is responsible for
      # removing the taint after it has finished initializing the node.
      # startupTaints:
      #   - key: example.com/another-taint
      #     effect: NoSchedule

      # Requirements that constrain the parameters of provisioned nodes.
      # These requirements are combined with pod.spec.topologySpreadConstraints, pod.spec.affinity.nodeAffinity, pod.spec.affinity.podAffinity, and pod.spec.nodeSelector rules.
      # Operators { In, NotIn, Exists, DoesNotExist, Gt, and Lt } are supported.
      # https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#operators
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

  # Disruption section which describes the ways in which Karpenter can disrupt and replace Nodes
  # Configuration in this section constrains how aggressive Karpenter can be with performing operations
  # like rolling Nodes due to them hitting their maximum lifetime (expiry) or scaling down nodes to reduce cluster cost
  disruption:
    # Describes which types of Nodes Karpenter should consider for consolidation
    # If using 'WhenUnderutilized', Karpenter will consider all nodes for consolidation and attempt to remove or replace Nodes when it discovers that the Node is underutilized and could be changed to reduce cost
    # If using `WhenEmpty`, Karpenter will only consider nodes for consolidation that contain no workload pods
    consolidationPolicy: WhenUnderutilized

    # The amount of time a Node can live on the cluster before being removed
    # Avoiding long-running Nodes helps to reduce security vulnerabilities as well as to reduce the chance of issues that can plague Nodes with long uptimes such as file fragmentation or memory leaks from system processes
    # You can choose to disable expiration entirely by setting the string value 'Never' here
    expireAfter: 720h

  # Resource limits constrain the total size of the cluster.
  # Limits prevent Karpenter from creating new instances once the limit is exceeded.
  limits:
    cpu: "1000"
    memory: 1000Gi

EOF
  }
}

generate "provider-local" {
  path      = "provider-local.tf"
  if_exists = "overwrite"
  contents  = file("../eks-providers.tf")
}
