module "fargate_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "fargate"
}
