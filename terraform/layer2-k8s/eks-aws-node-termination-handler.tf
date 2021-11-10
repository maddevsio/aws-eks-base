locals {
  aws_node_termination_handler = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "aws-node-termination-handler")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "aws-node-termination-handler")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "aws-node-termination-handler")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "aws-node-termination-handler")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "aws-node-termination-handler")].version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "aws-node-termination-handler")].namespace
  }
}

#tfsec:ignore:kubernetes-network-no-public-egress tfsec:ignore:kubernetes-network-no-public-ingress
module "aws_node_termination_handler_namespace" {
  count = local.aws_node_termination_handler.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.aws_node_termination_handler.namespace
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
                name = local.aws_node_termination_handler.namespace
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

resource "helm_release" "aws_node_termination_handler" {
  count = local.aws_node_termination_handler.enabled ? 1 : 0

  name        = local.aws_node_termination_handler.name
  chart       = local.aws_node_termination_handler.chart
  repository  = local.aws_node_termination_handler.repository
  version     = local.aws_node_termination_handler_version
  namespace   = module.aws_node_termination_handler_namespace[count.index].name
  max_history = var.helm_release_history_size

  values = [
    file("${path.module}/templates/aws-node-termination-handler-values.yaml")
  ]

}
