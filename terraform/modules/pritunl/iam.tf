data "aws_iam_policy_document" "this" {
  statement {
    sid                   = "AllowAttachDetachVolume"
    actions               = ["ec2:AttachVolume",
                             "ec2:DetachVolume"
                            ]
    resources             = ["arn:aws:ec2:*:*:volume/${aws_ebs_volume.mongodb_data.id}",
                             "arn:aws:ec2:*:*:instance/*"
                            ]
  }

  statement {
    sid                   = "AllowAssociateEIP"
    actions               = ["ec2:AssociateAddress"]
    resources             = ["*"]

    # condition {
    #   test                = "StringEquals"
    #   variable            = "eip:ResourceTag/Name"

    #   values              = [var.name]
    # }
  }
  statement {
    sid                   = "AllowModifyInstanceAttribute"
    actions               = ["ec2:ModifyInstanceAttribute"]
    resources             = ["arn:aws:ec2:*:*:instance/*"]

    condition {
      test                = "StringEquals"
      variable            = "ec2:ResourceTag/Name"

      values              = [var.name]
    }
  }
}

module "iam_policy" {
  source                  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version                 = "~> 2.0"

  name                    = var.name
  path                    = "/"
  description             = "${var.name} policy"

  policy                  =  data.aws_iam_policy_document.this.json
}

module "this_role" {
  source                  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version                 = "~> 2.0"

  trusted_role_services   = [
                            "ec2.amazonaws.com"
  ]

  create_role             = true

  role_name               = var.name
  role_requires_mfa       = false

  custom_role_policy_arns = [
                            module.iam_policy.arn,
                            "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
                            ]
}

resource "aws_iam_instance_profile" "this_instance_profile" {
  name                    = "${var.name}-discovery-profile"
  role                    = module.this_role.this_iam_role_name
}
