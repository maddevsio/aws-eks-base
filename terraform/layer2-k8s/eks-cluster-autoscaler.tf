locals {
  cluster_autoscaler = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "cluster-autoscaler")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "cluster-autoscaler")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "cluster-autoscaler")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "cluster-autoscaler")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "cluster-autoscaler")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "cluster-autoscaler")].namespace
  }
  cluster_autoscaler_values = <<VALUES
image:
  tag: ${var.cluster_autoscaler_version}
awsRegion: ${local.region}
rbac:
  create: true
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: ${local.cluster_autoscaler.enabled ? module.aws_iam_autoscaler[0].role_arn : ""}
autoDiscovery:
  clusterName: ${local.eks_cluster_id}
extraArgs:
  skip-nodes-with-local-storage: false
  scale-down-utilization-threshold: 0.7
  expander: priority
expanderPriorities: |
  10:
    - eks-${local.eks_cluster_id}-ondemand.*
  50:
    - eks-${local.eks_cluster_id}-spot.*

serviceMonitor:
  enabled: true
  interval: 10s
  namespace: monitoring
  path: /metrics

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: eks.amazonaws.com/capacityType
          operator: In
          values:
            - ON_DEMAND
resources:
  limits:
    cpu: 100m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 320Mi
VALUES
}

#tfsec:ignore:kubernetes-network-no-public-egress tfsec:ignore:kubernetes-network-no-public-ingress
module "cluster_autoscaler_namespace" {
  count = local.cluster_autoscaler.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.cluster_autoscaler.namespace
  network_policies = [
    {
      name         = "default-deny"
      policy_types = ["Ingress", "Egress"]
      pod_selector = {}
    },
    {
      name         = "allow-this-namespace"
      policy_types = ["Ingress"]
      pod_selector = {}
      ingress = {
        from = [
          {
            namespace_selector = {
              match_labels = {
                name = local.cluster_autoscaler.namespace
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-monitoring"
      policy_types = ["Ingress"]
      pod_selector = {
        match_expressions = {
          key      = "app.kubernetes.io/name"
          operator = "In"
          values   = ["aws-cluster-autoscaler"]
        }
      }
      ingress = {
        ports = [
          {
            port     = "8085"
            protocol = "TCP"
          }
        ]
        from = [
          {
            namespace_selector = {
              match_labels = {
                name = "monitoring"
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-egress"
      policy_types = ["Egress"]
      pod_selector = {}
      egress = {
        to = [
          {
            ip_block = {
              cidr = "0.0.0.0/0"
              except = [
                "169.254.169.254/32"
              ]
            }
          }
        ]
      }
    }
  ]
}

#tfsec:ignore:aws-iam-no-policy-wildcards
module "aws_iam_autoscaler" {
  count = local.cluster_autoscaler.enabled ? 1 : 0

  source            = "../modules/aws-iam-eks-trusted"
  name              = "${local.name}-autoscaler"
  region            = local.region
  oidc_provider_arn = local.eks_oidc_provider_arn
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "clusterAutoscalerAll",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeLaunchTemplateVersions",
          "autoscaling:DescribeTags",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeAutoScalingGroups",
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "clusterAutoscalerOwn",
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "autoscaling:SetDesiredCapacity",
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "autoscaling:ResourceTag/kubernetes.io/cluster/${local.eks_cluster_id}" : ["owned"],
            "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled" : ["true"]
          }
        }
      }
    ]
  })
}

resource "helm_release" "cluster_autoscaler" {
  count = local.cluster_autoscaler.enabled ? 1 : 0

  name        = local.cluster_autoscaler.name
  chart       = local.cluster_autoscaler.chart
  repository  = local.cluster_autoscaler.repository
  version     = local.cluster_autoscaler.chart_version
  namespace   = module.cluster_autoscaler_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    local.cluster_autoscaler_values
  ]

  depends_on = [kubectl_manifest.kube_prometheus_stack_operator_crds]
}
