data "aws_iam_policy_document" "this" {
  statement {
    sid = "AllowMountEFS"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]
    resources = [
      "arn:aws:elasticfilesystem:*:*:file-system/${aws_efs_file_system.this.id}"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [var.encrypted]
    }
  }

  statement {
    sid     = "AllowAssociateEIP"
    actions = ["ec2:AssociateAddress"]
    resources = ["arn:aws:ec2:*:*:elastic-ip/${aws_eip.this.id}",
      "arn:aws:ec2:*:*:instance/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Name"

      values = [var.name]
    }
  }

  statement {
    sid     = "AllowDisassociateAddressEIP"
    actions = ["ec2:DisassociateAddress"]
    resources = ["arn:aws:ec2:*:*:elastic-ip/${aws_eip.this.id}",
      "arn:aws:ec2:*:*:instance/*"
    ]
  }

  statement {
    sid       = "AllowModifyInstanceAttribute"
    actions   = ["ec2:ModifyInstanceAttribute"]
    resources = ["arn:aws:ec2:*:*:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Name"

      values = [var.name]
    }
  }
}

module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "4.14.0"

  name        = var.name
  path        = "/"
  description = "${var.name} policy"

  policy = data.aws_iam_policy_document.this.json
}

module "this_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "4.14.0"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  create_role = true

  role_name         = var.name
  role_requires_mfa = false

  custom_role_policy_arns = [
    module.iam_policy.arn,
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

resource "aws_iam_instance_profile" "this_instance_profile" {
  name = var.name
  role = module.this_role.iam_role_name
}

module "backup_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "4.14.0"

  trusted_role_services = [
    "backup.amazonaws.com"
  ]

  create_role = true

  role_name         = "${var.name}-backup-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  ]
}
