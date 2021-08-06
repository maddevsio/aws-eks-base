resource "aws_kms_key" "eks" {
  count       = var.eks_cluster_encryption_config_enable ? 1 : 0
  description = "EKS Secret Encryption Key"
}
