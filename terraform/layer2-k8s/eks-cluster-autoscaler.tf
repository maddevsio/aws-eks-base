locals {
  cluster-autoscaler = {
    chart         = local.helm_charts[index(local.helm_charts.*.id, "cluster-autoscaler")].chart
    repository    = lookup(local.helm_charts[index(local.helm_charts.*.id, "cluster-autoscaler")], "repository", null)
    chart_version = lookup(local.helm_charts[index(local.helm_charts.*.id, "cluster-autoscaler")], "version", null)
  }
}

data "template_file" "cluster_autoscaler" {
  template = file("${path.module}/templates/cluster-autoscaler-values.yaml")

  vars = {
    role_arn     = module.aws_iam_autoscaler.role_arn
    region       = local.region
    cluster_name = local.eks_cluster_id
    version      = var.cluster_autoscaler_version
  }
}

module "cluster_autoscaler_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "cluster-autoscaler"
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
                name = "cluster-autoscaler"
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
  source = "../modules/aws-iam-eks-trusted"

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
  name        = "cluster-autoscaler"
  chart       = local.cluster-autoscaler.chart
  repository  = local.cluster-autoscaler.repository
  version     = local.cluster-autoscaler.chart_version
  namespace   = module.cluster_autoscaler_namespace.name
  max_history = var.helm_release_history_size

  values = [
    data.template_file.cluster_autoscaler.rendered,
  ]

  depends_on = [helm_release.prometheus_operator]
}
