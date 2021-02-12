module "eks-fargate-profile" {
  source       = "terraform-module/eks-fargate-profile/aws"
  version      = "2.2.6"
  subnet_ids   = module.vpc.private_subnets
  cluster_name = module.eks.cluster_id
  namespaces   = ["fargate", "ci"]
}
