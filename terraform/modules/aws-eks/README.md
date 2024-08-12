## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_ebs_csi_driver"></a> [aws\_ebs\_csi\_driver](#module\_aws\_ebs\_csi\_driver) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.39.1 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 20.20.0 |
| <a name="module_vpc_cni_irsa"></a> [vpc\_cni\_irsa](#module\_vpc\_cni\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.39.1 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster_auth.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of access entries to add to the cluster | `any` | `{}` | no |
| <a name="input_eks_cloudwatch_log_group_retention_in_days"></a> [eks\_cloudwatch\_log\_group\_retention\_in\_days](#input\_eks\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events. Default retention - 90 days. | `number` | `90` | no |
| <a name="input_eks_cluster_enabled_log_types"></a> [eks\_cluster\_enabled\_log\_types](#input\_eks\_cluster\_enabled\_log\_types) | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html). Possible values: api, audit, authenticator, controllerManager, scheduler | `list(string)` | <pre>[<br>  "audit"<br>]</pre> | no |
| <a name="input_eks_cluster_encryption_config_enable"></a> [eks\_cluster\_encryption\_config\_enable](#input\_eks\_cluster\_encryption\_config\_enable) | Enable or not encryption for k8s secrets with aws-kms | `bool` | `false` | no |
| <a name="input_eks_cluster_endpoint_only_pritunl"></a> [eks\_cluster\_endpoint\_only\_pritunl](#input\_eks\_cluster\_endpoint\_only\_pritunl) | Only Pritunl VPN server will have access to eks endpoint. | `bool` | `false` | no |
| <a name="input_eks_cluster_endpoint_private_access"></a> [eks\_cluster\_endpoint\_private\_access](#input\_eks\_cluster\_endpoint\_private\_access) | Enable or not private access to cluster endpoint | `bool` | `true` | no |
| <a name="input_eks_cluster_endpoint_public_access"></a> [eks\_cluster\_endpoint\_public\_access](#input\_eks\_cluster\_endpoint\_public\_access) | Enable or not public access to cluster endpoint | `bool` | `true` | no |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | Version of the EKS K8S cluster | `string` | `"1.29"` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_intra_subnets"></a> [intra\_subnets](#input\_intra\_subnets) | A list of intra subnets inside the VPC | `list(any)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name, required to create unique resource names | `string` | n/a | yes |
| <a name="input_node_group_default"></a> [node\_group\_default](#input\_node\_group\_default) | Default node group configuration | <pre>object({<br>    instance_type              = string<br>    max_capacity               = number<br>    min_capacity               = number<br>    desired_capacity           = number<br>    capacity_rebalance         = bool<br>    use_mixed_instances_policy = bool<br>    mixed_instances_policy     = any<br>  })</pre> | <pre>{<br>  "capacity_rebalance": true,<br>  "desired_capacity": 2,<br>  "instance_type": "t4g.medium",<br>  "max_capacity": 3,<br>  "min_capacity": 2,<br>  "mixed_instances_policy": {<br>    "instances_distribution": {<br>      "on_demand_base_capacity": 0,<br>      "on_demand_percentage_above_base_capacity": 0<br>    },<br>    "override": [<br>      {<br>        "instance_type": "t4g.small"<br>      },<br>      {<br>        "instance_type": "t4g.medium"<br>      }<br>    ]<br>  },<br>  "use_mixed_instances_policy": true<br>}</pre> | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnets inside the VPC | `list(any)` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | A list of public subnets inside the VPC | `list(any)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Infrastructure region | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of additional tags to add to resources | `any` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where cluster will created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | Endpoint for EKS control plane. |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | n/a |
| <a name="output_eks_cluster_security_group_id"></a> [eks\_cluster\_security\_group\_id](#output\_eks\_cluster\_security\_group\_id) | Security group ids attached to the cluster control plane. |
| <a name="output_eks_kubectl_console_config"></a> [eks\_kubectl\_console\_config](#output\_eks\_kubectl\_console\_config) | description |
| <a name="output_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#output\_eks\_oidc\_provider\_arn) | ARN of EKS oidc provider |
| <a name="output_node_group_default_iam_role_arn"></a> [node\_group\_default\_iam\_role\_arn](#output\_node\_group\_default\_iam\_role\_arn) | n/a |
| <a name="output_node_group_default_iam_role_name"></a> [node\_group\_default\_iam\_role\_name](#output\_node\_group\_default\_iam\_role\_name) | n/a |
