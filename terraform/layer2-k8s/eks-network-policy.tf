# helm chart WIP, run:
# kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.6/config/v1.6/calico.yaml
# 
# resource "helm_release" "calico_daemonset" {
#   name       = "calico-daemonset"
#   chart      = "../../helm-charts/calico-daemonset"
#   namespace  = "kube-system"
# }

module "dev_ns_network_policy" {
  source                = "../modules/kubernetes-network-policy"
  namespace             = kubernetes_namespace.dev.metadata[0].name
  allow_from_namespaces = [module.ing_namespace.labels_name]

  # depends = [helm_release.calico_daemonset]
}
