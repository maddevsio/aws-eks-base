<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.1.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.10.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 1.14.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.10.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.14.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | 3.3.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 18.9.0 |
| <a name="module_pritunl"></a> [pritunl](#module\_pritunl) | ../modules/aws-ec2-pritunl | n/a |
| <a name="module_r53_zone"></a> [r53\_zone](#module\_r53\_zone) | terraform-aws-modules/route53/aws//modules/zones | 2.5.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.12.0 |
| <a name="module_vpc_gateway_endpoints"></a> [vpc\_gateway\_endpoints](#module\_vpc\_gateway\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | 3.12.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ebs_encryption_by_default.this](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/ebs_encryption_by_default) | resource |
| [aws_kms_key.eks](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/kms_key) | resource |
| [kubectl_manifest.this](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [aws_acm_certificate.main](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/acm_certificate) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.main](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.main](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/eks_cluster_auth) | data source |
| [aws_route53_zone.main](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/route53_zone) | data source |
| [aws_security_group.default](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/security_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_account_ids"></a> [allowed\_account\_ids](#input\_allowed\_account\_ids) | List of allowed AWS account IDs | `list` | `[]` | no |
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | IP addresses allowed to connect to private resources | `list(any)` | `[]` | no |
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Count of avaiablity zones, min 2 | `number` | `3` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | Default CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_create_acm_certificate"></a> [create\_acm\_certificate](#input\_create\_acm\_certificate) | Whether to create acm certificate or use existing | `bool` | `false` | no |
| <a name="input_create_r53_zone"></a> [create\_r53\_zone](#input\_create\_r53\_zone) | Create R53 zone for main public domain | `bool` | `false` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Main public domain name | `any` | n/a | yes |
| <a name="input_eks_addons"></a> [eks\_addons](#input\_eks\_addons) | A list of installed EKS add-ons | `map` | <pre>{<br>  "coredns": {<br>    "addon_version": "v1.8.4-eksbuild.1",<br>    "resolve_conflicts": "OVERWRITE"<br>  },<br>  "kube-proxy": {<br>    "addon_version": "v1.21.2-eksbuild.2",<br>    "resolve_conflicts": "OVERWRITE"<br>  },<br>  "vpc-cni": {<br>    "addon_version": "v1.10.2-eksbuild.1",<br>    "resolve_conflicts": "OVERWRITE"<br>  }<br>}</pre> | no |
| <a name="input_eks_cloudwatch_log_group_retention_in_days"></a> [eks\_cloudwatch\_log\_group\_retention\_in\_days](#input\_eks\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events. Default retention - 90 days. | `number` | `90` | no |
| <a name="input_eks_cluster_enabled_log_types"></a> [eks\_cluster\_enabled\_log\_types](#input\_eks\_cluster\_enabled\_log\_types) | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html). Possible values: api, audit, authenticator, controllerManager, scheduler | `list(string)` | <pre>[<br>  "audit"<br>]</pre> | no |
| <a name="input_eks_cluster_encryption_config_enable"></a> [eks\_cluster\_encryption\_config\_enable](#input\_eks\_cluster\_encryption\_config\_enable) | Enable or not encryption for k8s secrets with aws-kms | `bool` | `false` | no |
| <a name="input_eks_cluster_endpoint_only_pritunl"></a> [eks\_cluster\_endpoint\_only\_pritunl](#input\_eks\_cluster\_endpoint\_only\_pritunl) | Only Pritunl VPN server will have access to eks endpoint. | `bool` | `false` | no |
| <a name="input_eks_cluster_endpoint_private_access"></a> [eks\_cluster\_endpoint\_private\_access](#input\_eks\_cluster\_endpoint\_private\_access) | Enable or not private access to cluster endpoint | `bool` | `false` | no |
| <a name="input_eks_cluster_endpoint_public_access"></a> [eks\_cluster\_endpoint\_public\_access](#input\_eks\_cluster\_endpoint\_public\_access) | Enable or not public access to cluster endpoint | `bool` | `true` | no |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | Version of the EKS K8S cluster | `string` | `"1.21"` | no |
| <a name="input_eks_map_roles"></a> [eks\_map\_roles](#input\_eks\_map\_roles) | Additional IAM roles to add to the aws-auth configmap. | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_eks_workers_additional_policies"></a> [eks\_workers\_additional\_policies](#input\_eks\_workers\_additional\_policies) | Additional IAM policy attached to EKS worker nodes | `list(any)` | <pre>[<br>  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"<br>]</pre> | no |
| <a name="input_eks_write_kubeconfig"></a> [eks\_write\_kubeconfig](#input\_eks\_write\_kubeconfig) | Flag for eks module to write kubeconfig | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Env name in case workspace wasn't used | `string` | `"demo"` | no |
| <a name="input_name"></a> [name](#input\_name) | Project name, required to create unique resource names | `any` | n/a | yes |
| <a name="input_node_group_br"></a> [node\_group\_br](#input\_node\_group\_br) | Bottlerocket node group configuration | <pre>object({<br>    instance_types       = list(string)<br>    capacity_type        = string<br>    max_capacity         = number<br>    min_capacity         = number<br>    desired_capacity     = number<br>    force_update_version = bool<br>  })</pre> | <pre>{<br>  "capacity_type": "SPOT",<br>  "desired_capacity": 0,<br>  "force_update_version": true,<br>  "instance_types": [<br>    "t3a.medium",<br>    "t3.medium"<br>  ],<br>  "max_capacity": 5,<br>  "min_capacity": 0<br>}</pre> | no |
| <a name="input_node_group_ci"></a> [node\_group\_ci](#input\_node\_group\_ci) | CI node group configuration | <pre>object({<br>    instance_types       = list(string)<br>    capacity_type        = string<br>    max_capacity         = number<br>    min_capacity         = number<br>    desired_capacity     = number<br>    force_update_version = bool<br>  })</pre> | <pre>{<br>  "capacity_type": "SPOT",<br>  "desired_capacity": 0,<br>  "force_update_version": true,<br>  "instance_types": [<br>    "t3a.medium",<br>    "t3.medium"<br>  ],<br>  "max_capacity": 5,<br>  "min_capacity": 0<br>}</pre> | no |
| <a name="input_node_group_ondemand"></a> [node\_group\_ondemand](#input\_node\_group\_ondemand) | Default ondemand node group configuration | <pre>object({<br>    instance_types       = list(string)<br>    capacity_type        = string<br>    max_capacity         = number<br>    min_capacity         = number<br>    desired_capacity     = number<br>    force_update_version = bool<br>  })</pre> | <pre>{<br>  "capacity_type": "ON_DEMAND",<br>  "desired_capacity": 1,<br>  "force_update_version": true,<br>  "instance_types": [<br>    "t3a.medium"<br>  ],<br>  "max_capacity": 5,<br>  "min_capacity": 1<br>}</pre> | no |
| <a name="input_node_group_spot"></a> [node\_group\_spot](#input\_node\_group\_spot) | Spot node group configuration | <pre>object({<br>    instance_types       = list(string)<br>    capacity_type        = string<br>    max_capacity         = number<br>    min_capacity         = number<br>    desired_capacity     = number<br>    force_update_version = bool<br>  })</pre> | <pre>{<br>  "capacity_type": "SPOT",<br>  "desired_capacity": 1,<br>  "force_update_version": true,<br>  "instance_types": [<br>    "t3a.medium",<br>    "t3.medium"<br>  ],<br>  "max_capacity": 5,<br>  "min_capacity": 0<br>}</pre> | no |
| <a name="input_pritunl_vpn_access_cidr_blocks"></a> [pritunl\_vpn\_access\_cidr\_blocks](#input\_pritunl\_vpn\_access\_cidr\_blocks) | IP address that will have access to the web console | `string` | `"127.0.0.1/32"` | no |
| <a name="input_pritunl_vpn_server_enable"></a> [pritunl\_vpn\_server\_enable](#input\_pritunl\_vpn\_server\_enable) | Indicates whether or not the Pritunl VPN server is deployed. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | Default infrastructure region | `string` | `"us-east-1"` | no |
| <a name="input_short_region"></a> [short\_region](#input\_short\_region) | The abbreviated name of the region, required to form unique resource names | `map` | <pre>{<br>  "ap-east-1": "ape1",<br>  "ap-northeast-1": "apn1",<br>  "ap-northeast-2": "apn2",<br>  "ap-south-1": "aps1",<br>  "ap-southeast-1": "apse1",<br>  "ap-southeast-2": "apse2",<br>  "ca-central-1": "cac1",<br>  "cn-north-1": "cnn1",<br>  "cn-northwest-1": "cnnw1",<br>  "eu-central-1": "euc1",<br>  "eu-north-1": "eun1",<br>  "eu-west-1": "euw1",<br>  "eu-west-2": "euw2",<br>  "eu-west-3": "euw3",<br>  "sa-east-1": "sae1",<br>  "us-east-1": "use1",<br>  "us-east-2": "use2",<br>  "us-gov-east-1": "usge1",<br>  "us-gov-west-1": "usgw1",<br>  "us-west-1": "usw1",<br>  "us-west-2": "usw2"<br>}</pre> | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Flag to create single nat gateway for all AZs | `bool` | `true` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | R53 zone id for public domain | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_allowed_ips"></a> [allowed\_ips](#output\_allowed\_ips) | List of allowed ip's, used for direct ssh access to instances. |
| <a name="output_az_count"></a> [az\_count](#output\_az\_count) | Count of avaiablity zones, min 2 |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | Domain name |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | Endpoint for EKS control plane. |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | n/a |
| <a name="output_eks_cluster_security_group_id"></a> [eks\_cluster\_security\_group\_id](#output\_eks\_cluster\_security\_group\_id) | Security group ids attached to the cluster control plane. |
| <a name="output_eks_kubectl_console_config"></a> [eks\_kubectl\_console\_config](#output\_eks\_kubectl\_console\_config) | description |
| <a name="output_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#output\_eks\_oidc\_provider\_arn) | ARN of EKS oidc provider |
| <a name="output_env"></a> [env](#output\_env) | Suffix for the hostname depending on workspace |
| <a name="output_name"></a> [name](#output\_name) | Project name, required to form unique resource names |
| <a name="output_name_wo_region"></a> [name\_wo\_region](#output\_name\_wo\_region) | Project name, required to form unique resource names without short region |
| <a name="output_region"></a> [region](#output\_region) | Target region for all infrastructure resources |
| <a name="output_route53_zone_id"></a> [route53\_zone\_id](#output\_route53\_zone\_id) | ID of domain zone |
| <a name="output_short_region"></a> [short\_region](#output\_short\_region) | The abbreviated name of the region, required to form unique resource names |
| <a name="output_ssl_certificate_arn"></a> [ssl\_certificate\_arn](#output\_ssl\_certificate\_arn) | ARN of SSL certificate |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | CIDR block of infra VPC |
| <a name="output_vpc_database_subnets"></a> [vpc\_database\_subnets](#output\_vpc\_database\_subnets) | Database subnets of infra VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of infra VPC |
| <a name="output_vpc_intra_subnets"></a> [vpc\_intra\_subnets](#output\_vpc\_intra\_subnets) | Private intra subnets |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | Name of infra VPC |
| <a name="output_vpc_private_subnets"></a> [vpc\_private\_subnets](#output\_vpc\_private\_subnets) | Private subnets of infra VPC |
| <a name="output_vpc_public_subnets"></a> [vpc\_public\_subnets](#output\_vpc\_public\_subnets) | Public subnets of infra VPC |
<!-- END_TF_DOCS -->