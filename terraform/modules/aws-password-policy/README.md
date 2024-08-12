## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_account_password_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_password_policy"></a> [aws\_account\_password\_policy](#input\_aws\_account\_password\_policy) | n/a | `any` | <pre>{<br>  "allow_users_to_change_password": true,<br>  "hard_expiry": false,<br>  "max_password_age": 90,<br>  "minimum_password_length": 14,<br>  "password_reuse_prevention": 10,<br>  "require_lowercase_characters": true,<br>  "require_numbers": true,<br>  "require_symbols": true,<br>  "require_uppercase_characters": true<br>}</pre> | no |

## Outputs

No outputs.
