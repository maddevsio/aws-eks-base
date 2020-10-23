resource "aws_iam_role" "dlm_lifecycle_role" {
  name                  = "${var.name}-dlm-lifecycle-role"

  assume_role_policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "dlm_lifecycle" {
  name                  = "${var.name}-dlm-lifecycle-policy"
  role                  = aws_iam_role.dlm_lifecycle_role.id

  policy                = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateSnapshot",
            "ec2:DeleteSnapshot",
            "ec2:DescribeVolumes",
            "ec2:DescribeSnapshots"
         ],
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateTags"
         ],
         "Resource": "arn:aws:ec2:*::snapshot/*"
      }
   ]
}
EOF
}

resource "aws_dlm_lifecycle_policy" "this" {
  description           = "${var.name} DLM lifecycle policy"
  execution_role_arn    = aws_iam_role.dlm_lifecycle_role.arn
  state                 = "ENABLED"

  policy_details {
    resource_types      = ["VOLUME"]

    schedule {
      name              = "1 week of daily snapshots"

      create_rule {
        interval        = 24
        interval_unit   = "HOURS"
        times           = ["23:45"]
      }

      retain_rule {
        count           = 7
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags         = true
    }

    target_tags = {
      Name              = var.name
      Environment       = var.environment
    }
  }
}
