## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_namespace"></a> [namespace](#module\_namespace) | ../eks-kubernetes-namespace | n/a |
| <a name="module_this"></a> [this](#module\_this) | terraform-aws-modules/eks/aws//modules/karpenter | 20.17.2 |

## Resources

| Name | Type |
|------|------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.ec2nodeclass_private](https://registry.terraform.io/providers/hashicorp/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.ec2nodeclass_public](https://registry.terraform.io/providers/hashicorp/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.nodepool](https://registry.terraform.io/providers/hashicorp/kubectl/latest/docs/resources/manifest) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecrpublic_authorization_token.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecrpublic_authorization_token) | data source |
| [aws_eks_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | ID of the created EKS cluster. | `string` | n/a | yes |
| <a name="input_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#input\_eks\_oidc\_provider\_arn) | ARN of EKS oidc provider | `string` | n/a | yes |
| <a name="input_helm"></a> [helm](#input\_helm) | The configuratin of the Karpenter helm release | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name, required to create unique resource names | `string` | n/a | yes |
| <a name="input_node_group_default_iam_role_arn"></a> [node\_group\_default\_iam\_role\_arn](#input\_node\_group\_default\_iam\_role\_arn) | The IAM Role ARN of a default nodegroup | `string` | `""` | no |
| <a name="input_node_group_default_iam_role_name"></a> [node\_group\_default\_iam\_role\_name](#input\_node\_group\_default\_iam\_role\_name) | The IAM Role name of a default nodegroup | `string` | `""` | no |
| <a name="input_nodepools"></a> [nodepools](#input\_nodepools) | Kubernetes manifests to create Karpenter Nodepool objects | `any` | `[]` | no |

## Outputs

No outputs.
