module "eventbridge" {
  count   = var.aws_cis_benchmark_alerts.enabled ? 1 : 0
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "1.14.0"

  create_bus = false

  rules = {
    secrets_manager_actions = {
      enabled     = var.aws_cis_benchmark_alerts.rules.secrets_manager_actions_enabled
      description = "Capture all Secret Manager events"
      event_pattern = jsonencode(
        {
          "source" : ["aws.secretsmanager"],
          "detail" : {
            "eventSource" : ["secretsmanager.amazonaws.com"],
            "eventName" : ["CreateSecret", "UpdateSecret", "DeleteSecret", "PutSecretValue"]
          }
        }
      )
    },
    parameter_store_actions = {
      enabled     = var.aws_cis_benchmark_alerts.rules.parameter_store_actions_enabled
      description = "Capture all Parameter Store events"
      event_pattern = jsonencode(
        {
          "source" : ["aws.ssm"],
          "detail-type" : ["Parameter Store Change"],
          "detail" : {
            "operation" : ["Create", "Update", "Delete", "LabelParameterVersion"]
          }
        }
      )
    },
    console_login_failed = {
      enabled     = var.aws_cis_benchmark_alerts.rules.console_login_failed_enabled
      description = "Alert on ConsoleLogin failed authentication"
      event_pattern = jsonencode(
        {
          "detail" : {
            "eventName" : ["ConsoleLogin"],
            "errorMessage" : ["Failed authentication"]
          }
        }
      )
    },
    kms_cmk_delete_or_disable = {
      enabled     = var.aws_cis_benchmark_alerts.rules.kms_cmk_delete_or_disable_enabled
      description = "Alert on KMS disable or delete CMK"
      event_pattern = jsonencode(
        {
          "source" : ["aws.kms"],
          "detail-type" : ["AWS API Call via CloudTrail"],
          "detail" : {
            "eventSource" : ["kms.amazonaws.com"],
            "eventName" : [
              "DisableKey",
              "ScheduleKeyDeletion"
            ]
          }
        }
      )
    },
    consolelogin_without_mfa = {
      enabled     = var.aws_cis_benchmark_alerts.rules.console_login_failed_enabled
      description = "Alert on ConsoleLogin without MFA"
      event_pattern = jsonencode(
        {
          "detail-type" : ["AWS Console Sign In via CloudTrail"],
          "detail" : {
            "eventName" : ["ConsoleLogin"],
            "userIdentity" : {
              "type" : ["IAMUser"]
            },
            "additionalEventData" : {
              "MFAUsed" : [{ "anything-but" : "Yes" }]
            },
            "responseElements" : {
              "ConsoleLogin" : ["Success"]
            }
          }
        }
      )
    },
    unauthorized_api_calls = {
      enabled     = var.aws_cis_benchmark_alerts.rules.unauthorized_api_calls_enabled
      description = "Alert on Unauthorized-API-Calls"
      event_pattern = jsonencode(
        {
          "detail-type" : ["AWS API Call via CloudTrail"],
          "errorCode" : ["AccessDenied", "*UnauthorizedOperation"]
        }
      )
    },
    usage_of_root_account = {
      enabled     = var.aws_cis_benchmark_alerts.rules.usage_of_root_account_enabled
      description = "Alert on usage of Root account"
      event_pattern = jsonencode(
        {
          "detail-type" : ["AWS Console Sign In via CloudTrail"],
          "detail" : {
            "userIdentity" : {
              "type" : ["Root"],
              "invokedBy" : [{ "exists" : false }]
            },
            "eventType" : [{ "anything-but" : "AwsServiceEvent" }]
          }
        }
      )
    },
    iam_policy_changes = {
      enabled     = var.aws_cis_benchmark_alerts.rules.iam_policy_changes_enabled
      description = "Alert on changing IAM policy"
      event_pattern = jsonencode(
        {
          "source" : ["aws.iam"],
          "detail-type" : ["AWS API Call via CloudTrail"],
          "detail" : {
            "eventSource" : ["iam.amazonaws.com"],
            "eventName" : [
              "DeleteGroupPolicy",
              "DeleteRolePolicy",
              "DeleteUserPolicy",
              "PutGroupPolicy",
              "PutRolePolicy",
              "PutUserPolicy",
              "CreatePolicy",
              "DeletePolicy",
              "CreatePolicyVersion",
              "DeletePolicyVersion",
              "AttachRolePolicy",
              "DetachRolePolicy",
              "AttachUserPolicy",
              "DetachUserPolicy",
              "AttachGroupPolicy",
              "DetachGroupPolicy"
            ]
          }
        }
      )
    },
    cloudtrail_configuration_changes = {
      enabled     = var.aws_cis_benchmark_alerts.rules.cloudtrail_configuration_changes_enabled
      description = "Alert on changing Cloudtrail configuration"
      event_pattern = jsonencode(
        {
          "source" : ["aws.cloudtrail"],
          "detail-type" : ["AWS API Call via CloudTrail"],
          "detail" : {
            "eventSource" : ["cloudtrail.amazonaws.com"],
            "eventName" : [
              "CreateTrail",
              "UpdateTrail",
              "DeleteTrail",
              "StartLogging",
              "StopLogging"
            ]
          }
        }
      )
    },
    s3_bucket_policy_changes = {
      enabled     = var.aws_cis_benchmark_alerts.rules.s3_bucket_policy_changes_enabled
      description = "Alert on changing s3 bucket policy"
      event_pattern = jsonencode(
        {
          "source" : ["aws.s3"],
          "detail-type" : ["AWS API Call via CloudTrail"],
          "detail" : {
            "eventSource" : ["s3.amazonaws.com"],
            "eventName" : [
              "PutBucketAcl",
              "PutBucketPolicy",
              "PutBucketCors",
              "PutBucketLifecycle",
              "PutBucketReplication",
              "DeleteBucketPolicy",
              "DeleteBucketCors",
              "DeleteBucketLifecycle",
              "DeleteBucketReplication"
            ]
          }
        }
      )
    },
    aws_config_changes = {
      enabled     = var.aws_cis_benchmark_alerts.rules.aws_config_changes_enabled
      description = "Alert on changing AWS Config configuration"
      event_pattern = jsonencode(
        {
          "source" : ["aws.config"],
          "detail-type" : ["AWS API Call via CloudTrail"],
          "detail" : {
            "eventSource" : ["config.amazonaws.com"],
            "eventName" : [
              "StopConfigurationRecorder",
              "DeleteDeliveryChannel",
              "PutDeliveryChannel",
              "PutConfigurationRecorder"
            ]
          }
        }
      )
    },
    security_group_changes = {
      enabled     = var.aws_cis_benchmark_alerts.rules.security_group_changes_enabled
      description = "Alert on changing Security groups"
      event_pattern = jsonencode(
        {
          "source" : ["aws.ec2"],
          "detail-type" : ["AWS API Call via CloudTrail"],
          "detail" : {
            "eventSource" : ["ec2.amazonaws.com"],
            "eventName" : [
              "AuthorizeSecurityGroupIngress",
              "AuthorizeSecurityGroupEgress",
              "RevokeSecurityGroupIngress",
              "RevokeSecurityGroupEgress",
              "CreateSecurityGroup",
              "DeleteSecurityGroup"
            ]
          }
        }
      )
    },
    nacl_changes = {
      enabled     = var.aws_cis_benchmark_alerts.rules.nacl_changes_enabled
      description = "Alert on changing NACL"
      event_pattern = jsonencode(
        {
          "source" : ["aws.ec2"],
          "detail-type" : ["AWS API Call via CloudTrail"],
          "detail" : {
            "eventSource" : ["ec2.amazonaws.com"],
            "eventName" : [
              "CreateNetworkAcl",
              "CreateNetworkAclEntry",
              "DeleteNetworkAcl",
              "DeleteNetworkAclEntry",
              "ReplaceNetworkAclEntry",
              "ReplaceNetworkAclAssociation"
            ]
          }
        }
      )
    },
    network_gateway_changes = {
      enabled     = var.aws_cis_benchmark_alerts.rules.network_gateway_changes_enabled
      description = "Alert on changing Network Gateways"
      event_pattern = jsonencode(
        {
          "source" : ["aws.ec2"],
          "detail-type" : ["AWS API Call via CloudTrail"],
          "detail" : {
            "eventSource" : ["ec2.amazonaws.com"],
            "eventName" : [
              "CreateCustomerGateway",
              "DeleteCustomerGateway",
              "AttachInternetGateway",
              "CreateInternetGateway",
              "DeleteInternetGateway",
              "DetachInternetGateway"
            ]
          }
        }
      )
    },
    route_table_changes = {
      enabled     = var.aws_cis_benchmark_alerts.rules.route_table_changes_enabled
      description = "Alert on changing Route tables"
      event_pattern = jsonencode(
        {
          "source" : ["aws.ec2"],
          "detail-type" : ["AWS API Call via CloudTrail"],
          "detail" : {
            "eventSource" : ["ec2.amazonaws.com"],
            "eventName" : [
              "CreateRoute",
              "CreateRouteTable",
              "ReplaceRoute",
              "ReplaceRouteTableAssociation",
              "DeleteRouteTable",
              "DeleteRoute",
              "DisassociateRouteTable"
            ]
          }
        }
      )
    },
    vpc_changes = {
      enabled     = var.aws_cis_benchmark_alerts.rules.vpc_changes_enabled
      description = "Alert on changing VPC configuration"
      event_pattern = jsonencode(
        {
          "source" : ["aws.ec2"],
          "detail-type" : ["AWS API Call via CloudTrail"],
          "detail" : {
            "eventSource" : ["ec2.amazonaws.com"],
            "eventName" : [
              "CreateVpc",
              "DeleteVpc",
              "ModifyVpcAttribute",
              "AcceptVpcPeeringConnection",
              "CreateVpcPeeringConnection",
              "DeleteVpcPeeringConnection",
              "RejectVpcPeeringConnection",
              "AttachClassicLinkVpc",
              "DetachClassicLinkVpc",
              "DisableVpcClassicLink",
              "EnableVpcClassicLink"
            ]
          }
        }
      )
    },
    organization_changes = {
      enabled     = var.aws_cis_benchmark_alerts.rules.organization_changes_enabled
      description = "Alert on Organization changes"
      event_pattern = jsonencode(
        {
          "source" : ["aws.organizations"],
          "detail-type" : ["AWS API Call via CloudTrail"],
          "detail" : {
            "eventSource" : ["organizations.amazonaws.com"],
            "eventName" : [
              "AcceptHandshake",
              "AttachPolicy",
              "CreateAccount",
              "CreateOrganizationalUnit",
              "CreatePolicy",
              "DeclineHandshake",
              "DeleteOrganization",
              "DeleteOrganizationalUnit",
              "DeletePolicy",
              "DetachPolicy",
              "DisablePolicyType",
              "EnablePolicyType",
              "InviteAccountToOrganization",
              "LeaveOrganization",
              "MoveAccount",
              "RemoveAccountFromOrganization",
              "UpdatePolicy",
              "UpdateOrganizationalUnit"
            ]
          }
        }
      )
    },
  }

  targets = {
    secrets_manager_actions = [
      {
        name = "secrets-manager-actions-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ],
    parameter_store_actions = [
      {
        name = "parameter-store-actions-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ],
    console_login_failed = [
      {
        name = "console-login-failed-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ],
    kms_cmk_delete_or_disable = [
      {
        name = "kms-cmk-delete-or-disable-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ]
    consolelogin_without_mfa = [
      {
        name = "consolelogin-without-mfa-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ],
    unauthorized_api_calls = [
      {
        name = "unauthorized-api-calls-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ],
    usage_of_root_account = [
      {
        name = "usage-of-root-account-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ],
    iam_policy_changes = [
      {
        name = "iam-policy-changes-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ],
    cloudtrail_configuration_changes = [
      {
        name = "cloudtrail-configuration-changes-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ],
    s3_bucket_policy_changes = [
      {
        name = "s3-bucket-policy-changes-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ],
    aws_config_changes = [
      {
        name = "aws-config-changes-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ],
    security_group_changes = [
      {
        name = "security-group-changes-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ],
    nacl_changes = [
      {
        name = "nacl-changes-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ],
    network_gateway_changes = [
      {
        name = "network-gateway-changes-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ],
    route_table_changes = [
      {
        name = "route-table-changes-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ],
    vpc_changes = [
      {
        name = "vpc-changes-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ],
    organization_changes = [
      {
        name = "organization-changes-notify-via-sns"
        arn  = aws_sns_topic.security_alerts[count.index].arn
      }
    ]
  }

  tags = local.tags
}

#tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "security_alerts" {
  count = var.aws_cis_benchmark_alerts.enabled ? 1 : 0

  name = "${local.name}-security-alerts"

  tags = local.tags
}

resource "aws_sns_topic_subscription" "security_alerts" {
  count = var.aws_cis_benchmark_alerts.enabled ? 1 : 0

  topic_arn = aws_sns_topic.security_alerts[count.index].arn
  protocol  = "email"
  endpoint  = var.aws_cis_benchmark_alerts.email
}

resource "aws_sns_topic_policy" "security_alerts" {
  count = var.aws_cis_benchmark_alerts.enabled ? 1 : 0

  arn = aws_sns_topic.security_alerts[count.index].arn
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Allow_Publish_Events",
        "Effect" : "Allow",
        "Principal" : { "Service" : "events.amazonaws.com" },
        "Action" : "sns:Publish",
        "Resource" : [
          aws_sns_topic.security_alerts[count.index].arn
        ]
      },
      {
        "Sid" : "__default_statement_ID",
        "Effect" : "Allow",
        "Principal" : { "AWS" : "*" },
        "Action" : [
          "sns:GetTopicAttributes",
          "sns:SetTopicAttributes",
          "sns:AddPermission",
          "sns:RemovePermission",
          "sns:DeleteTopic",
          "sns:Subscribe",
          "sns:ListSubscriptionsByTopic",
          "sns:Publish",
          "sns:Receive"
        ]
        "Resource" : [
          aws_sns_topic.security_alerts[count.index].arn
        ]
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceOwner" : data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}
