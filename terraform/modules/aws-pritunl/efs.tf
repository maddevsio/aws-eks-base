#------------------------------------------------------------------------------
# Create EFS
#------------------------------------------------------------------------------
resource "aws_efs_file_system" "this" {
  creation_token = var.name
  encrypted      = var.encrypted
  kms_key_id     = var.kms_key_id

  tags = {
    "Name" = var.name
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_efs_mount_target" "this" {
  count          = length(var.public_subnets)
  file_system_id = aws_efs_file_system.this.id
  subnet_id      = var.public_subnets[count.index]
  security_groups = [
    module.efs_sg.security_group_id
  ]
}
