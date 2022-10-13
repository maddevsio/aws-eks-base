<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [tls_private_key.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [external_external.this_p8](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_name"></a> [common\_name](#input\_common\_name) | n/a | `string` | `"localhost"` | no |
| <a name="input_dns_names"></a> [dns\_names](#input\_dns\_names) | n/a | `list(any)` | <pre>[<br>  "localhost"<br>]</pre> | no |
| <a name="input_early_renewal_hours"></a> [early\_renewal\_hours](#input\_early\_renewal\_hours) | n/a | `string` | `336` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `"example"` | no |
| <a name="input_validity_period_hours"></a> [validity\_period\_hours](#input\_validity\_period\_hours) | n/a | `string` | `8760` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cert_pem"></a> [cert\_pem](#output\_cert\_pem) | n/a |
| <a name="output_p8"></a> [p8](#output\_p8) | n/a |
| <a name="output_private_key_pem"></a> [private\_key\_pem](#output\_private\_key\_pem) | n/a |
<!-- END_TF_DOCS -->
