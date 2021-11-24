provider "aws" {
  region              = local.region
  allowed_account_ids = var.allowed_account_ids
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.main.token
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.main.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.main.token
  }

  experiments {
    manifest = true
  }
}

data "aws_eks_cluster" "main" {
  name = local.eks_cluster_id
}

data "aws_eks_cluster_auth" "main" {
  name = local.eks_cluster_id
}
