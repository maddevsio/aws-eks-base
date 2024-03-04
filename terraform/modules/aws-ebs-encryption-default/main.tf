resource "aws_ebs_encryption_by_default" "this" {
  enabled = var.enable
}
