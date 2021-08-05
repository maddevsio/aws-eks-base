## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| helm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| chart\_name | Helm  Chart name | `string` | `"aws-load-balancer-controller"` | no |
| chart\_version | Chart version repository name | `string` | `"1.2.6"` | no |
| eks\_cluster\_id | EKC identity cluster | `string` | `""` | no |
| image\_tag | chart version alb ingress | `string` | `"v2.2.3"` | no |
| max\_history | How much helm releases to store | `number` | `"5"` | no |
| name | Project name, required to create unique resource names | `string` | `""` | no |
| namespace | Name of kubernetes namespace for alb\_ingres | `string` | `""` | no |
| oidc\_provider\_arn | ARN of EKS oidc provider | `string` | `""` | no |
| region | eks infrastructure region | `string` | `""` | no |
| release\_name | Helm  Release name | `string` | `"aws-load-balancer-controller"` | no |
| replica\_count | Default number of replicas | `number` | `1` | no |
| repository | Repository name for eks | `string` | `"https://aws.github.io/eks-charts"` | no |
| values | helm chat template file | `map(any)` | `{}` | no |
| vpc\_id | EKS cluster vps identity | `string` | `""` | no |

## Outputs

No output.

