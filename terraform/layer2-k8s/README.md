## Requirements

| Name | Version |
|------|---------|
| terraform | 0.15.1 |
| aws | 3.38.0 |
| helm | 2.1.2 |
| kubernetes | 2.1.0 |

## Providers

| Name | Version |
|------|---------|
| aws | 3.38.0 |
| helm | 2.1.2 |
| kubernetes | 2.1.0 |
| template | n/a |
| terraform | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_allowed\_ips | IP addresses allowed to connect to private resources | `list(any)` | `[]` | no |
| alb\_ingress\_chart\_version | Version of alb-ingress helm chart | `string` | `"1.0.4"` | no |
| alb\_ingress\_image\_tag | Tag of docker image for alb-ingress controller | `string` | `"v1.1.5"` | no |
| allowed\_account\_ids | List of allowed AWS account IDs | `list` | `[]` | no |
| aws\_node\_termination\_handler\_version | Version of aws-node-termination-handler helm chart | `string` | `"0.13.3"` | no |
| calico\_daemonset | Version of calico helm chart | `string` | `"0.3.4"` | no |
| cert\_manager\_version | Version of cert-manager helm chart | `string` | `"1.1.0"` | no |
| cluster\_autoscaler\_chart\_version | Version of cluster autoscaler helm chart | `string` | `"9.9.2"` | no |
| cluster\_autoscaler\_version | Version of cluster autoscaler | `string` | `"v1.19.0"` | no |
| elk\_index\_retention\_days | Days before remove index from system elasticsearch | `number` | `14` | no |
| elk\_snapshot\_retention\_days | Days to capture index in snapshot | `number` | `90` | no |
| elk\_version | Version of ELK helm chart | `string` | `"7.8.0"` | no |
| external\_dns\_version | Version of external-dns helm chart | `string` | `"4.9.4"` | no |
| external\_secrets\_version | Version of external-secrets helm chart | `string` | `"6.3.0"` | no |
| gitlab\_runner\_version | Version of gitlab runner helm chart | `string` | `"0.26.0"` | no |
| loki\_stack | Version of Loki Stack helm chart | `string` | `"2.3.1"` | no |
| nginx\_ingress\_controller\_version | Version of nginx-ingress helm chart | `string` | `"3.23.0"` | no |
| nginx\_ingress\_ssl\_terminator | Select SSL termination type | `string` | `"lb"` | no |
| oauth2\_proxy\_version | Version of the oauth-proxy chart | `string` | `"3.2.5"` | no |
| prometheus\_mysql\_exporter\_version | Version of prometheus mysql-exporter helm chart | `string` | `"1.1.0"` | no |
| prometheus\_operator\_version | Version of prometheus operator helm chart | `string` | `"13.12.0"` | no |
| redis\_version | Version of redis helm chart | `string` | `"12.7.3"` | no |
| region | Default infrastructure region | `string` | `"us-east-1"` | no |
| reloader\_version | Version of reloader helm chart | `string` | `"0.0.81"` | no |
| remote\_state\_bucket | Name of the bucket for terraform state | `string` | n/a | yes |
| remote\_state\_key | Key of the remote state for terraform\_remote\_state | `string` | `"layer1-aws"` | no |

## Outputs

No output.

