## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_iam_alb_ingress_controller"></a> [aws\_iam\_alb\_ingress\_controller](#module\_aws\_iam\_alb\_ingress\_controller) | ../aws-iam-alb-ingress-controller | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.alb_ingress_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_ingress_image_tag"></a> [alb\_ingress\_image\_tag](#input\_alb\_ingress\_image\_tag) | chart version alb ingress | `string` | `"1.2.3"` | no |
| <a name="input_aws-load-balancer-controller"></a> [aws-load-balancer-controller](#input\_aws-load-balancer-controller) | Helm  Release name | `string` | `"aws-load-balancer-controller"` | no |
| <a name="input_chart_name"></a> [chart\_name](#input\_chart\_name) | Helm  Chart name | `string` | `"aws-load-balancer-controller"` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Chart version repository name | `string` | `"aws-alb-ingress-controller"` | no |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKC identity cluster | `string` | `""` | no |
| <a name="input_max_history"></a> [max\_history](#input\_max\_history) | How much helm releases to store | `string` | `"5"` | no |
| <a name="input_name"></a> [name](#input\_name) | Project name, required to create unique resource names | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Name of kubernetes namespace for alb\_ingres | `string` | `""` | no |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | ARN of EKS oidc provider | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | eks infrastructure region | `string` | `""` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository name for eks | `string` | `"https://aws.github.io/eks-charts"` | no |
| <a name="input_values"></a> [values](#input\_values) | helm chat template file | `map(any)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | EKS cluster vps identity | `string` | `""` | no |

## Outputs

No outputs.

