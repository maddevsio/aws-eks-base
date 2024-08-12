## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_r53_zone"></a> [r53\_zone](#module\_r53\_zone) | terraform-aws-modules/route53/aws//modules/zones | 2.11.1 |

## Resources

| Name | Type |
|------|------|
| [aws_route53_zone.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_r53_zone"></a> [create\_r53\_zone](#input\_create\_r53\_zone) | Create R53 zone for main public domain | `bool` | `false` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Main public domain name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_route53_zone_id"></a> [route53\_zone\_id](#output\_route53\_zone\_id) | ID of domain zone |
