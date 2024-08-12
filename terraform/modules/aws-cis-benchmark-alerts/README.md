## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eventbridge"></a> [eventbridge](#module\_eventbridge) | terraform-aws-modules/eventbridge/aws | 3.3.1 |

## Resources

| Name | Type |
|------|------|
| [aws_sns_topic.security_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.security_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.security_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_cis_benchmark_alerts"></a> [aws\_cis\_benchmark\_alerts](#input\_aws\_cis\_benchmark\_alerts) | AWS CIS Benchmark alerts configuration | `any` | <pre>{<br>  "email": "demo@example.com",<br>  "enabled": "false",<br>  "rules": {<br>    "aws_config_changes_enabled": true,<br>    "cloudtrail_configuration_changes_enabled": true,<br>    "console_login_failed_enabled": true,<br>    "consolelogin_without_mfa_enabled": true,<br>    "iam_policy_changes_enabled": true,<br>    "kms_cmk_delete_or_disable_enabled": true,<br>    "nacl_changes_enabled": true,<br>    "network_gateway_changes_enabled": true,<br>    "organization_changes_enabled": true,<br>    "parameter_store_actions_enabled": true,<br>    "route_table_changes_enabled": true,<br>    "s3_bucket_policy_changes_enabled": true,<br>    "secrets_manager_actions_enabled": true,<br>    "security_group_changes_enabled": true,<br>    "unauthorized_api_calls_enabled": true,<br>    "usage_of_root_account_enabled": true,<br>    "vpc_changes_enabled": true<br>  }<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Project name, required to create unique resource names | `string` | n/a | yes |

## Outputs

No outputs.
