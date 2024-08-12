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
| [aws_wafv2_ip_set.owasp_10_detect_blacklisted_ips](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_rule_group.owasp_top10_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_rule_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_blacklisted_cidrs"></a> [blacklisted\_cidrs](#input\_blacklisted\_cidrs) | A list of blacklister CIDR blocks | `list(string)` | <pre>[<br>  "10.0.0.0/8",<br>  "192.168.0.0/16",<br>  "169.254.0.0/16",<br>  "172.16.0.0/16",<br>  "127.0.0.1/32"<br>]</pre> | no |
| <a name="input_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#input\_cloudwatch\_metrics\_enabled) | Enable or not using AWS Cloudwatch metrics | `bool` | `false` | no |
| <a name="input_csrf_expected_header"></a> [csrf\_expected\_header](#input\_csrf\_expected\_header) | The custom HTTP request header, where the CSRF token value is expected to be encountered | `string` | `"x-csrf-token"` | no |
| <a name="input_csrf_expected_size"></a> [csrf\_expected\_size](#input\_csrf\_expected\_size) | The size in bytes of the CSRF token value. For example if it's a canonically formatted UUIDv4 value the expected size would be 36 bytes/ASCII characters. | `string` | `"36"` | no |
| <a name="input_max_expected_body_size"></a> [max\_expected\_body\_size](#input\_max\_expected\_body\_size) | Maximum number of bytes allowed in the body of the request. If you do not plan to allow large uploads, set it to the largest payload value that makes sense for your web application. Accepting unnecessarily large values can cause performance issues, if large payloads are used as an attack vector against your web application. | `string` | `"4096"` | no |
| <a name="input_max_expected_cookie_size"></a> [max\_expected\_cookie\_size](#input\_max\_expected\_cookie\_size) | Maximum number of bytes allowed in the cookie header. The maximum size should be less than 4096, the size is determined by the amount of information your web application stores in cookies. If you only pass a session token via cookies, set the size to no larger than the serialized size of the session token and cookie metadata. | `string` | `"4093"` | no |
| <a name="input_max_expected_query_string_size"></a> [max\_expected\_query\_string\_size](#input\_max\_expected\_query\_string\_size) | Maximum number of bytes allowed in the query string component of the HTTP request. Normally the  of query string parameters following the ? in a URL is much larger than the URI , but still bounded by the  of the parameters your web application uses and their values. | `string` | `"1024"` | no |
| <a name="input_max_expected_uri_size"></a> [max\_expected\_uri\_size](#input\_max\_expected\_uri\_size) | Maximum number of bytes allowed in the URI component of the HTTP request. Generally the maximum possible value is determined by the server operating system (maps to file system paths), the web server software, or other middleware components. Choose a value that accomodates the largest URI segment you use in practice in your web application. | `string` | `"512"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name used for all resources in this module | `string` | n/a | yes |
| <a name="input_waf_scope"></a> [waf\_scope](#input\_waf\_scope) | One API can be used for both global and regional applications. Possible values are CLOUDFRONT and REGIONAL. REGIONAL is used for ALBs, API Gateway | `string` | `"CLOUDFRONT"` | no |
| <a name="input_wafv2_rule_action"></a> [wafv2\_rule\_action](#input\_wafv2\_rule\_action) | Default rules action | `string` | `"block"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rule_group_arn"></a> [rule\_group\_arn](#output\_rule\_group\_arn) | n/a |
