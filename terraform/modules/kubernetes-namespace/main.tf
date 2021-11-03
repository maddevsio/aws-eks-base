# automatically add name to labels,
# if it is not set
locals {
  labels = merge({
    name = var.name
  }, var.labels)
}

resource "kubernetes_namespace" "this" {
  # option to disable namespace creation
  # e.g. if you want to create namespace only in specific environment
  count = var.enable ? 1 : 0

  metadata {
    annotations = var.annotations
    labels      = local.labels
    name        = var.name
  }

  depends_on = [var.depends]
}
