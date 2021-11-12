resource "kubernetes_storage_class" "advanced" {
  metadata {
    name = "advanced"
  }
  storage_provisioner    = "kubernetes.io/aws-ebs"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
  parameters = {
    type      = "gp2"
    fsType    = "ext4"
    encrypted = "true" # It is set to true for cases when global EBS encryption is disabled.
  }
}
