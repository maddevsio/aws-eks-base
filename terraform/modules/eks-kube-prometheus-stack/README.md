## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| helm | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alertmanager\_domain\_name | Domain name for alertmanager | `string` | n/a | yes |
| alertmanager\_enabled | Enable or disable alertmanager | `bool` | `false` | no |
| alertmanager\_slack\_channel | Slack channel name for alertmanager | `string` | `""` | no |
| alertmanager\_slack\_url | Slack webhook for alertmanager | `string` | `""` | no |
| domain\_name | Domain name used to build subdomains | `string` | n/a | yes |
| eks\_oidc\_provider\_arn | ARN of EKS oidc provider | `string` | n/a | yes |
| grafana\_domain\_name | Domain name for grafana | `string` | n/a | yes |
| grafana\_enabled | Enable or disable grafana | `bool` | `true` | no |
| grafana\_github\_oauth\_enabled | Enable or disable github oauth for grafana | `bool` | `false` | no |
| grafana\_gitlab\_oauth\_enabled | Enable or disable gitlab oauth for grafana | `bool` | `false` | no |
| grafana\_oauth\_client\_id | Oauth client id for grafana | `string` | `""` | no |
| grafana\_oauth\_client\_secret | Oauth client id secret for grafana | `string` | `""` | no |
| grafana\_oauth\_github\_allowed\_org | Github allowed organizations | `string` | `""` | no |
| grafana\_oauth\_github\_teams\_ids | Github teams ids | `string` | `""` | no |
| grafana\_oauth\_gitlab\_group | Gitlab group | `string` | `""` | no |
| grafana\_storage\_size | Grafana storage size | `string` | `"5Gi"` | no |
| helm\_release\_history\_size | How much helm releases to store | `number` | `5` | no |
| helm\_release\_wait | Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as timeout. Defaults to true. | `string` | `false` | no |
| helm\_repo\_prometheus\_community | Repository name for kube-prometheus-stack | `string` | `"https://prometheus-community.github.io/helm-charts"` | no |
| ip\_whitelist | Whitelist ip's for access to prometheus and alertmanager | `string` | `""` | no |
| kube\_prometheus\_stack\_version | Kube-prometheus-stack chart version | `string` | `"13.12.0"` | no |
| kubernetes\_namespace | Name of kubernetes namespace for prometheus stack | `string` | n/a | yes |
| name | Project name, required to create unique resource names | `string` | n/a | yes |
| prometheus\_domain\_name | Domain name for prometheus | `string` | n/a | yes |
| prometheus\_storage\_size | Prometheus storage size | `string` | `"30Gi"` | no |
| region | Default infrastructure region | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| alertmanager\_domain\_name | Alertmanager ui address |
| grafana\_admin\_password | Grafana admin password |
| grafana\_domain\_name | Grafana dashboards address |
| prometheus\_domain\_name | Prometheus ui address |
