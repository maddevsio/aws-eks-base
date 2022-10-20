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
| <a name="module_eventbridge"></a> [eventbridge](#module\_eventbridge) | terraform-aws-modules/eventbridge/aws | 1.14.0 |
| <a name="module_pritunl"></a> [pritunl](#module\_pritunl) | ../modules/aws-pritunl | n/a |
| <a name="module_r53_zone"></a> [r53\_zone](#module\_r53\_zone) | terraform-aws-modules/route53/aws//modules/zones | 2.5.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.12.0 |
| <a name="module_vpc_cni_irsa"></a> [vpc\_cni\_irsa](#module\_vpc\_cni\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 4.14.0 |
| <a name="module_vpc_gateway_endpoints"></a> [vpc\_gateway\_endpoints](#module\_vpc\_gateway\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | 3.12.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.main](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/cloudtrail) | resource |
| [aws_ebs_encryption_by_default.default](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/ebs_encryption_by_default) | resource |
| [aws_iam_account_password_policy.default](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/iam_account_password_policy) | resource |
| [aws_kms_key.eks](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/kms_key) | resource |
| [aws_s3_bucket.cloudtrail](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.cloudtrail](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.cloudtrail](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.cloudtrail](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.cloudtrail](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_sns_topic.security_alerts](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.security_alerts](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.security_alerts](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/sns_topic_subscription) | resource |
| [kubectl_manifest.aws_auth_configmap](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [aws_acm_certificate.main](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/acm_certificate) | data source |
| [aws_ami.eks_default_bottlerocket](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/ami) | data source |
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
| <a name="input_aws_account_password_policy"></a> [aws\_account\_password\_policy](#input\_aws\_account\_password\_policy) | n/a | `any` | <pre>{<br>  "allow_users_to_change_password": true,<br>  "create": true,<br>  "hard_expiry": false,<br>  "max_password_age": 90,<br>  "minimum_password_length": 14,<br>  "password_reuse_prevention": 10,<br>  "require_lowercase_characters": true,<br>  "require_numbers": true,<br>  "require_symbols": true,<br>  "require_uppercase_characters": true<br>}</pre> | no |
| <a name="input_aws_cis_benchmark_alerts"></a> [aws\_cis\_benchmark\_alerts](#input\_aws\_cis\_benchmark\_alerts) | AWS CIS Benchmark alerts configuration | `any` | <pre>{<br>  "email": "demo@example.com",<br>  "enabled": "false",<br>  "rules": {<br>    "aws_config_changes_enabled": true,<br>    "cloudtrail_configuration_changes_enabled": true,<br>    "console_login_failed_enabled": true,<br>    "consolelogin_without_mfa_enabled": true,<br>    "iam_policy_changes_enabled": true,<br>    "kms_cmk_delete_or_disable_enabled": true,<br>    "nacl_changes_enabled": true,<br>    "network_gateway_changes_enabled": true,<br>    "organization_changes_enabled": true,<br>    "parameter_store_actions_enabled": true,<br>    "route_table_changes_enabled": true,<br>    "s3_bucket_policy_changes_enabled": true,<br>    "secrets_manager_actions_enabled": true,<br>    "security_group_changes_enabled": true,<br>    "unauthorized_api_calls_enabled": true,<br>    "usage_of_root_account_enabled": true,<br>    "vpc_changes_enabled": true<br>  }<br>}</pre> | no |
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Count of avaiablity zones, min 2 | `number` | `3` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | Default CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_cloudtrail_logs_s3_expiration_days"></a> [cloudtrail\_logs\_s3\_expiration\_days](#input\_cloudtrail\_logs\_s3\_expiration\_days) | How many days keep cloudtrail logs on S3 | `string` | `180` | no |
| <a name="input_create_acm_certificate"></a> [create\_acm\_certificate](#input\_create\_acm\_certificate) | Whether to create acm certificate or use existing | `bool` | `false` | no |
| <a name="input_create_r53_zone"></a> [create\_r53\_zone](#input\_create\_r53\_zone) | Create R53 zone for main public domain | `bool` | `false` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Main public domain name | `any` | n/a | yes |
| <a name="input_eks_addons"></a> [eks\_addons](#input\_eks\_addons) | A list of installed EKS add-ons | `map` | <pre>{<br>  "coredns": {<br>    "addon_version": "v1.8.7-eksbuild.1",<br>    "resolve_conflicts": "OVERWRITE"<br>  },<br>  "kube-proxy": {<br>    "addon_version": "v1.22.6-eksbuild.1",<br>    "resolve_conflicts": "OVERWRITE"<br>  },<br>  "vpc-cni": {<br>    "addon_version": "v1.11.0-eksbuild.1",<br>    "resolve_conflicts": "OVERWRITE"<br>  }<br>}</pre> | no |
| <a name="input_eks_cloudwatch_log_group_retention_in_days"></a> [eks\_cloudwatch\_log\_group\_retention\_in\_days](#input\_eks\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events. Default retention - 90 days. | `number` | `90` | no |
| <a name="input_eks_cluster_enabled_log_types"></a> [eks\_cluster\_enabled\_log\_types](#input\_eks\_cluster\_enabled\_log\_types) | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html). Possible values: api, audit, authenticator, controllerManager, scheduler | `list(string)` | <pre>[<br>  "audit"<br>]</pre> | no |
| <a name="input_eks_cluster_encryption_config_enable"></a> [eks\_cluster\_encryption\_config\_enable](#input\_eks\_cluster\_encryption\_config\_enable) | Enable or not encryption for k8s secrets with aws-kms | `bool` | `false` | no |
| <a name="input_eks_cluster_endpoint_only_pritunl"></a> [eks\_cluster\_endpoint\_only\_pritunl](#input\_eks\_cluster\_endpoint\_only\_pritunl) | Only Pritunl VPN server will have access to eks endpoint. | `bool` | `false` | no |
| <a name="input_eks_cluster_endpoint_private_access"></a> [eks\_cluster\_endpoint\_private\_access](#input\_eks\_cluster\_endpoint\_private\_access) | Enable or not private access to cluster endpoint | `bool` | `false` | no |
| <a name="input_eks_cluster_endpoint_public_access"></a> [eks\_cluster\_endpoint\_public\_access](#input\_eks\_cluster\_endpoint\_public\_access) | Enable or not public access to cluster endpoint | `bool` | `true` | no |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | Version of the EKS K8S cluster | `string` | `"1.22"` | no |
| <a name="input_eks_map_roles"></a> [eks\_map\_roles](#input\_eks\_map\_roles) | Additional IAM roles to add to the aws-auth configmap. | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_eks_workers_additional_policies"></a> [eks\_workers\_additional\_policies](#input\_eks\_workers\_additional\_policies) | Additional IAM policy attached to EKS worker nodes | `list(any)` | <pre>[<br>  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"<br>]</pre> | no |
| <a name="input_eks_write_kubeconfig"></a> [eks\_write\_kubeconfig](#input\_eks\_write\_kubeconfig) | Flag for eks module to write kubeconfig | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Env name in case workspace wasn't used | `string` | `"demo"` | no |
| <a name="input_name"></a> [name](#input\_name) | Project name, required to create unique resource names | `any` | n/a | yes |
| <a name="input_node_group_br"></a> [node\_group\_br](#input\_node\_group\_br) | Bottlerocket node group configuration | <pre>object({<br>    instance_type              = string<br>    max_capacity               = number<br>    min_capacity               = number<br>    desired_capacity           = number<br>    capacity_rebalance         = bool<br>    use_mixed_instances_policy = bool<br>    mixed_instances_policy     = any<br>  })</pre> | <pre>{<br>  "capacity_rebalance": true,<br>  "desired_capacity": 0,<br>  "instance_type": "t3.medium",<br>  "max_capacity": 5,<br>  "min_capacity": 0,<br>  "mixed_instances_policy": {<br>    "instances_distribution": {<br>      "on_demand_base_capacity": 0,<br>      "on_demand_percentage_above_base_capacity": 0<br>    },<br>    "override": [<br>      {<br>        "instance_type": "t3.medium"<br>      },<br>      {<br>        "instance_type": "t3a.medium"<br>      }<br>    ]<br>  },<br>  "use_mixed_instances_policy": true<br>}</pre> | no |
| <a name="input_node_group_ci"></a> [node\_group\_ci](#input\_node\_group\_ci) | CI node group configuration | <pre>object({<br>    instance_type              = string<br>    max_capacity               = number<br>    min_capacity               = number<br>    desired_capacity           = number<br>    capacity_rebalance         = bool<br>    use_mixed_instances_policy = bool<br>    mixed_instances_policy     = any<br>  })</pre> | <pre>{<br>  "capacity_rebalance": false,<br>  "desired_capacity": 0,<br>  "instance_type": "t3.medium",<br>  "max_capacity": 5,<br>  "min_capacity": 0,<br>  "mixed_instances_policy": {<br>    "instances_distribution": {<br>      "on_demand_base_capacity": 0,<br>      "on_demand_percentage_above_base_capacity": 0<br>    },<br>    "override": [<br>      {<br>        "instance_type": "t3.medium"<br>      },<br>      {<br>        "instance_type": "t3a.medium"<br>      }<br>    ]<br>  },<br>  "use_mixed_instances_policy": true<br>}</pre> | no |
| <a name="input_node_group_ondemand"></a> [node\_group\_ondemand](#input\_node\_group\_ondemand) | Default ondemand node group configuration | <pre>object({<br>    instance_type              = string<br>    max_capacity               = number<br>    min_capacity               = number<br>    desired_capacity           = number<br>    capacity_rebalance         = bool<br>    use_mixed_instances_policy = bool<br>    mixed_instances_policy     = any<br>  })</pre> | <pre>{<br>  "capacity_rebalance": false,<br>  "desired_capacity": 1,<br>  "instance_type": "t3a.medium",<br>  "max_capacity": 5,<br>  "min_capacity": 1,<br>  "mixed_instances_policy": null,<br>  "use_mixed_instances_policy": false<br>}</pre> | no |
| <a name="input_node_group_spot"></a> [node\_group\_spot](#input\_node\_group\_spot) | Spot node group configuration | <pre>object({<br>    instance_type              = string<br>    max_capacity               = number<br>    min_capacity               = number<br>    desired_capacity           = number<br>    capacity_rebalance         = bool<br>    use_mixed_instances_policy = bool<br>    mixed_instances_policy     = any<br>  })</pre> | <pre>{<br>  "capacity_rebalance": true,<br>  "desired_capacity": 1,<br>  "instance_type": "t3.medium",<br>  "max_capacity": 5,<br>  "min_capacity": 0,<br>  "mixed_instances_policy": {<br>    "instances_distribution": {<br>      "on_demand_base_capacity": 0,<br>      "on_demand_percentage_above_base_capacity": 0<br>    },<br>    "override": [<br>      {<br>        "instance_type": "t3.medium"<br>      },<br>      {<br>        "instance_type": "t3a.medium"<br>      }<br>    ]<br>  },<br>  "use_mixed_instances_policy": true<br>}</pre> | no |
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
