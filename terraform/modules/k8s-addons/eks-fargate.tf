# Calico is not supported when using Fargate with Amazon EKS (NetworkPolicies won't work)
module "fargate_namespace" {
  source = "../eks-kubernetes-namespace"
  name   = "fargate"
}
