## Requirements

| Name | Version |
|------|---------|
| terraform | 1.0.10 |
| aws | 3.64.2 |
| helm | 2.4.1 |
| kubernetes | 2.6.1 |

## Providers

| Name | Version |
|------|---------|
| aws | 3.64.2 |
| helm | 2.4.1 |
| random | n/a |
| template | n/a |
| terraform | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_allowed\_ips | IP addresses allowed to connect to private resources | `list(any)` | `[]` | no |
| allowed\_account\_ids | List of allowed AWS account IDs | `list` | `[]` | no |
| aws\_loadbalancer\_controller\_enable | Disable or Enable aws-loadbalancer-controller. You need to enable it if you want to use Fargate | `bool` | `false` | no |
| cluster\_autoscaler\_version | Version of cluster autoscaler | `string` | `"v1.21.0"` | no |
| elk\_index\_retention\_days | Days before remove index from system elasticsearch | `number` | `14` | no |
| elk\_snapshot\_retention\_days | Days to capture index in snapshot | `number` | `90` | no |
| helm\_release\_history\_size | How much helm releases to store | `number` | `5` | no |
| nginx\_ingress\_ssl\_terminator | Select SSL termination type | `string` | `"lb"` | no |
| region | Default infrastructure region | `string` | `"us-east-1"` | no |
| remote\_state\_bucket | Name of the bucket for terraform state | `string` | n/a | yes |
| remote\_state\_key | Key of the remote state for terraform\_remote\_state | `string` | `"layer1-aws"` | no |

## Outputs

| Name | Description |
|------|-------------|
| alertmanager\_domain\_name | Alertmanager ui address |
| get\_grafana\_admin\_password | Command which gets admin password from kubernetes secret |
| grafana\_admin\_password | Grafana admin password |
| grafana\_domain\_name | Grafana dashboards address |
| prometheus\_domain\_name | Prometheus ui address |

