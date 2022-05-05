#tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "security_alerts" {
  count = var.aws_cis_benchmark_alerts.enabled ? 1 : 0

  name = "${local.name}-security-alerts"
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
