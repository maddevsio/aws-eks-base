## Requirements

| Name | Version |
|------|---------|
| terraform | 0.15.1 |
| aws | 3.53.0 |
| kubernetes | 2.4.1 |

## Providers

| Name | Version |
|------|---------|
| aws | 3.53.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_account\_ids | List of allowed AWS account IDs | `list` | `[]` | no |
| allowed\_ips | IP addresses allowed to connect to private resources | `list(any)` | `[]` | no |
| az\_count | Count of avaiablity zones, min 2 | `number` | `3` | no |
| cidr | Default CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| create\_acm\_certificate | Whether to create acm certificate or use existing | `bool` | `false` | no |
| create\_r53\_zone | Create R53 zone for main public domain | `bool` | `false` | no |
| domain\_name | Main public domain name | `any` | n/a | yes |
| ecr\_repo\_retention\_count | number of images to store in ECR | `number` | `50` | no |
| ecr\_repos | List of docker repositories | `list(any)` | <pre>[<br>  "demo"<br>]</pre> | no |
| eks\_cluster\_enabled\_log\_types | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html). Possible values: api, audit, authenticator, controllerManager, scheduler | `list(string)` | <pre>[<br>  "audit"<br>]</pre> | no |
| eks\_cluster\_encryption\_config\_enable | Enable or not encryption for k8s secrets with aws-kms | `bool` | `false` | no |
| eks\_cluster\_log\_retention\_in\_days | Number of days to retain log events. Default retention - 90 days. | `number` | `90` | no |
| eks\_cluster\_version | Version of the EKS K8S cluster | `string` | `"1.21"` | no |
| eks\_map\_roles | Additional IAM roles to add to the aws-auth configmap. | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| eks\_workers\_additional\_policies | Additional IAM policy attached to EKS worker nodes | `list(any)` | <pre>[<br>  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"<br>]</pre> | no |
| eks\_write\_kubeconfig | Flag for eks module to write kubeconfig | `bool` | `false` | no |
| environment | Env name in case workspace wasn't used | `string` | `"demo"` | no |
| name | Project name, required to create unique resource names | `any` | n/a | yes |
| node\_group\_ci | Node group configuration | <pre>object({<br>    instance_types       = list(string)<br>    capacity_type        = string<br>    max_capacity         = number<br>    min_capacity         = number<br>    desired_capacity     = number<br>    force_update_version = bool<br>  })</pre> | <pre>{<br>  "capacity_type": "SPOT",<br>  "desired_capacity": 0,<br>  "force_update_version": true,<br>  "instance_types": [<br>    "t3a.medium",<br>    "t3.medium"<br>  ],<br>  "max_capacity": 5,<br>  "min_capacity": 0<br>}</pre> | no |
| node\_group\_ondemand | Node group configuration | <pre>object({<br>    instance_types       = list(string)<br>    capacity_type        = string<br>    max_capacity         = number<br>    min_capacity         = number<br>    desired_capacity     = number<br>    force_update_version = bool<br>  })</pre> | <pre>{<br>  "capacity_type": "ON_DEMAND",<br>  "desired_capacity": 1,<br>  "force_update_version": true,<br>  "instance_types": [<br>    "t3a.medium"<br>  ],<br>  "max_capacity": 5,<br>  "min_capacity": 1<br>}</pre> | no |
| node\_group\_spot | Node group configuration | <pre>object({<br>    instance_types       = list(string)<br>    capacity_type        = string<br>    max_capacity         = number<br>    min_capacity         = number<br>    desired_capacity     = number<br>    force_update_version = bool<br>  })</pre> | <pre>{<br>  "capacity_type": "SPOT",<br>  "desired_capacity": 1,<br>  "force_update_version": true,<br>  "instance_types": [<br>    "t3a.medium",<br>    "t3.medium"<br>  ],<br>  "max_capacity": 5,<br>  "min_capacity": 0<br>}</pre> | no |
| region | Default infrastructure region | `string` | `"us-east-1"` | no |
| short\_region | The abbreviated name of the region, required to form unique resource names | `map` | <pre>{<br>  "ap-east-1": "ape1",<br>  "ap-northeast-1": "apn1",<br>  "ap-northeast-2": "apn2",<br>  "ap-south-1": "aps1",<br>  "ap-southeast-1": "apse1",<br>  "ap-southeast-2": "apse2",<br>  "ca-central-1": "cac1",<br>  "cn-north-1": "cnn1",<br>  "cn-northwest-1": "cnnw1",<br>  "eu-central-1": "euc1",<br>  "eu-north-1": "eun1",<br>  "eu-west-1": "euw1",<br>  "eu-west-2": "euw2",<br>  "eu-west-3": "euw3",<br>  "sa-east-1": "sae1",<br>  "us-east-1": "use1",<br>  "us-east-2": "use2",<br>  "us-gov-east-1": "usge1",<br>  "us-gov-west-1": "usgw1",<br>  "us-west-1": "usw1",<br>  "us-west-2": "usw2"<br>}</pre> | no |
| single\_nat\_gateway | Flag to create single nat gateway for all AZs | `bool` | `true` | no |
| worker\_group\_bottlerocket | Bottlerocket worker group configuration | <pre>object({<br>    instance_types      = list(string)<br>    capacity_type       = string<br>    max_capacity        = number<br>    min_capacity        = number<br>    desired_capacity    = number<br>    spot_instance_pools = number<br>  })</pre> | <pre>{<br>  "capacity_type": "SPOT",<br>  "desired_capacity": 0,<br>  "instance_types": [<br>    "t3a.medium",<br>    "t3.medium"<br>  ],<br>  "max_capacity": 5,<br>  "min_capacity": 0,<br>  "spot_instance_pools": 2<br>}</pre> | no |
| zone\_id | R53 zone id for public domain | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| allowed\_ips | List of allowed ip's, used for direct ssh access to instances. |
| az\_count | Count of avaiablity zones, min 2 |
| domain\_name | Domain name |
| eks\_cluster\_endpoint | Endpoint for EKS control plane. |
| eks\_cluster\_id | n/a |
| eks\_cluster\_security\_group\_id | Security group ids attached to the cluster control plane. |
| eks\_config\_map\_aws\_auth | A kubernetes configuration to authenticate to this EKS cluster. |
| eks\_kubectl\_config | kubectl config as generated by the module. |
| eks\_kubectl\_console\_config | description |
| eks\_oidc\_provider\_arn | ARN of EKS oidc provider |
| env | Suffix for the hostname depending on workspace |
| name | Project name, required to form unique resource names |
| name\_wo\_region | Project name, required to form unique resource names without short region |
| region | Target region for all infrastructure resources |
| route53\_zone\_id | ID of domain zone |
| short\_region | The abbreviated name of the region, required to form unique resource names |
| ssl\_certificate\_arn | ARN of SSL certificate |
| vpc\_cidr | CIDR block of infra VPC |
| vpc\_database\_subnets | Database subnets of infra VPC |
| vpc\_id | ID of infra VPC |
| vpc\_intra\_subnets | Private intra subnets |
| vpc\_name | Name of infra VPC |
| vpc\_private\_subnets | Private subnets of infra VPC |
| vpc\_public\_subnets | Public subnets of infra VPC |

