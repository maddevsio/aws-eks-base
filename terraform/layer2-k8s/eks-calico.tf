data "template_file" "calico_daemonset" {
  template = file("${path.module}/templates/calico-values.yaml")
}

resource "helm_release" "calico_daemonset" {
  name        = "aws-calico"
  chart       = "aws-calico"
  repository  = local.helm_repo_eks
  version     = var.calico_daemonset
  namespace   = "kube-system"
  max_history = var.helm_release_history_size
  wait        = false

  values = [
    data.template_file.calico_daemonset.rendered,
  ]
}
