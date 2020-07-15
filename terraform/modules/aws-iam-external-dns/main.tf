resource "aws_iam_role" "this" {
  name_prefix        = "${var.name}-external-dns"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${var.oidc_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.${var.region}.amazonaws.com/id/${regex("[A-Z0-9]{32}", var.oidc_provider_arn)}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "this" {
  name_prefix = "${var.name}-external-dns"
  role        = aws_iam_role.this.id

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
     ],
     "Resource": [
       "arn:aws:route53:::hostedzone/*"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ListHostedZones"
     ],
     "Resource": [
       "*"
     ]
   },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }
 ]
}
EOF
}
