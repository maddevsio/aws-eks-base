## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.1.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.10.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.5.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 2.1.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 1.14.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.10.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.5.1 |
| <a name="provider_http"></a> [http](#provider\_http) | 2.1.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.14.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.10.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_iam_autoscaler"></a> [aws\_iam\_autoscaler](#module\_aws\_iam\_autoscaler) | ../modules/aws-iam-eks-trusted | n/a |
| <a name="module_aws_iam_aws_loadbalancer_controller"></a> [aws\_iam\_aws\_loadbalancer\_controller](#module\_aws\_iam\_aws\_loadbalancer\_controller) | ../modules/aws-iam-eks-trusted | n/a |
| <a name="module_aws_iam_cert_manager"></a> [aws\_iam\_cert\_manager](#module\_aws\_iam\_cert\_manager) | ../modules/aws-iam-eks-trusted | n/a |
| <a name="module_aws_iam_elastic_stack"></a> [aws\_iam\_elastic\_stack](#module\_aws\_iam\_elastic\_stack) | ../modules/aws-iam-user-with-policy | n/a |
| <a name="module_aws_iam_external_dns"></a> [aws\_iam\_external\_dns](#module\_aws\_iam\_external\_dns) | ../modules/aws-iam-eks-trusted | n/a |
| <a name="module_aws_iam_gitlab_runner"></a> [aws\_iam\_gitlab\_runner](#module\_aws\_iam\_gitlab\_runner) | ../modules/aws-iam-eks-trusted | n/a |
| <a name="module_aws_iam_kube_prometheus_stack_grafana"></a> [aws\_iam\_kube\_prometheus\_stack\_grafana](#module\_aws\_iam\_kube\_prometheus\_stack\_grafana) | ../modules/aws-iam-eks-trusted | n/a |
| <a name="module_aws_iam_victoria_metrics_k8s_stack_grafana"></a> [aws\_iam\_victoria\_metrics\_k8s\_stack\_grafana](#module\_aws\_iam\_victoria\_metrics\_k8s\_stack\_grafana) | ../modules/aws-iam-eks-trusted | n/a |
| <a name="module_aws_load_balancer_controller_namespace"></a> [aws\_load\_balancer\_controller\_namespace](#module\_aws\_load\_balancer\_controller\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_aws_node_termination_handler_namespace"></a> [aws\_node\_termination\_handler\_namespace](#module\_aws\_node\_termination\_handler\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_certmanager_namespace"></a> [certmanager\_namespace](#module\_certmanager\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_cluster_autoscaler_namespace"></a> [cluster\_autoscaler\_namespace](#module\_cluster\_autoscaler\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_elastic_tls"></a> [elastic\_tls](#module\_elastic\_tls) | ../modules/self-signed-certificate | n/a |
| <a name="module_elk_namespace"></a> [elk\_namespace](#module\_elk\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_external_dns_namespace"></a> [external\_dns\_namespace](#module\_external\_dns\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_external_secrets_namespace"></a> [external\_secrets\_namespace](#module\_external\_secrets\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_fargate_namespace"></a> [fargate\_namespace](#module\_fargate\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_gitlab_runner_namespace"></a> [gitlab\_runner\_namespace](#module\_gitlab\_runner\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_ingress_nginx_namespace"></a> [ingress\_nginx\_namespace](#module\_ingress\_nginx\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_istio_system_namespace"></a> [istio\_system\_namespace](#module\_istio\_system\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_keda_namespace"></a> [keda\_namespace](#module\_keda\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_kiali_namespace"></a> [kiali\_namespace](#module\_kiali\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_kube_prometheus_stack_namespace"></a> [kube\_prometheus\_stack\_namespace](#module\_kube\_prometheus\_stack\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_loki_namespace"></a> [loki\_namespace](#module\_loki\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_reloader_namespace"></a> [reloader\_namespace](#module\_reloader\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_tigera_operator_namespace"></a> [tigera\_operator\_namespace](#module\_tigera\_operator\_namespace) | ../modules/eks-kubernetes-namespace | n/a |
| <a name="module_victoria_metrics_k8s_stack_namespace"></a> [victoria\_metrics\_k8s\_stack\_namespace](#module\_victoria\_metrics\_k8s\_stack\_namespace) | ../modules/eks-kubernetes-namespace | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.default_ingress](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/route53_record) | resource |
| [aws_s3_bucket.elastic_stack](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.gitlab_runner_cache](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.elastic_stack_public_access_block](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.gitlab_runner_cache_public_access_block](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/s3_bucket_public_access_block) | resource |
| [helm_release.aws_loadbalancer_controller](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.aws_node_termination_handler](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.cert_manager](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.certificate](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.cluster_autoscaler](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.cluster_issuer](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.elk](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.external_dns](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.external_secrets](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.gitlab_runner](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.ingress_nginx](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.istio_base](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.istiod](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.kedacore](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.kiali](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.loki_stack](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.prometheus_operator](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.reloader](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.tigera_operator](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.victoria_metrics_k8s_stack](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [kubectl_manifest.calico_felix](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.istio_prometheus_service_monitor_cp](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.istio_prometheus_service_monitor_dp](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.kube_prometheus_stack_operator_crds](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubernetes_ingress_v1.default](https://registry.terraform.io/providers/kubernetes/2.10.0/docs/resources/ingress_v1) | resource |
| [kubernetes_secret.elasticsearch_certificates](https://registry.terraform.io/providers/kubernetes/2.10.0/docs/resources/secret) | resource |
| [kubernetes_secret.elasticsearch_credentials](https://registry.terraform.io/providers/kubernetes/2.10.0/docs/resources/secret) | resource |
| [kubernetes_secret.elasticsearch_s3_user_creds](https://registry.terraform.io/providers/kubernetes/2.10.0/docs/resources/secret) | resource |
| [kubernetes_secret.kibana_enc_key](https://registry.terraform.io/providers/kubernetes/2.10.0/docs/resources/secret) | resource |
| [kubernetes_storage_class.advanced](https://registry.terraform.io/providers/kubernetes/2.10.0/docs/resources/storage_class) | resource |
| [random_string.elasticsearch_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.kibana_enc_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.kibana_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.kube_prometheus_stack_grafana_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.victoria_metrics_k8s_stack_grafana_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_cert_request.aws_loadbalancer_controller_webhook](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.aws_loadbalancer_controller_webhook](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.aws_loadbalancer_controller_webhook](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.aws_loadbalancer_controller_webhook_ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.aws_loadbalancer_controller_webhook_ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.main](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.main](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/eks_cluster_auth) | data source |
| [aws_secretsmanager_secret.infra](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.infra](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/secretsmanager_secret_version) | data source |
| [http_http.kube_prometheus_stack_operator_crds](https://registry.terraform.io/providers/hashicorp/http/2.1.0/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_allowed_ips"></a> [additional\_allowed\_ips](#input\_additional\_allowed\_ips) | IP addresses allowed to connect to private resources | `list(any)` | `[]` | no |
| <a name="input_allowed_account_ids"></a> [allowed\_account\_ids](#input\_allowed\_account\_ids) | List of allowed AWS account IDs | `list` | `[]` | no |
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | IP addresses allowed to connect to private resources | `list(any)` | `[]` | no |
| <a name="input_cluster_autoscaler_version"></a> [cluster\_autoscaler\_version](#input\_cluster\_autoscaler\_version) | Version of cluster autoscaler | `string` | `"v1.22.0"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Main public domain name | `any` | n/a | yes |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | ID of the created EKS cluster. | `any` | n/a | yes |
| <a name="input_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#input\_eks\_oidc\_provider\_arn) | ARN of EKS oidc provider | `any` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Env name | `string` | `"demo"` | no |
| <a name="input_helm_release_history_size"></a> [helm\_release\_history\_size](#input\_helm\_release\_history\_size) | How much helm releases to store | `number` | `5` | no |
| <a name="input_name"></a> [name](#input\_name) | Project name, required to create unique resource names | `any` | n/a | yes |
| <a name="input_nginx_ingress_ssl_terminator"></a> [nginx\_ingress\_ssl\_terminator](#input\_nginx\_ingress\_ssl\_terminator) | Select SSL termination type | `string` | `"lb"` | no |
| <a name="input_region"></a> [region](#input\_region) | Default infrastructure region | `string` | `"us-east-1"` | no |
| <a name="input_short_region"></a> [short\_region](#input\_short\_region) | The abbreviated name of the region, required to form unique resource names | `map` | <pre>{<br>  "ap-east-1": "ape1",<br>  "ap-northeast-1": "apn1",<br>  "ap-northeast-2": "apn2",<br>  "ap-south-1": "aps1",<br>  "ap-southeast-1": "apse1",<br>  "ap-southeast-2": "apse2",<br>  "ca-central-1": "cac1",<br>  "cn-north-1": "cnn1",<br>  "cn-northwest-1": "cnnw1",<br>  "eu-central-1": "euc1",<br>  "eu-north-1": "eun1",<br>  "eu-west-1": "euw1",<br>  "eu-west-2": "euw2",<br>  "eu-west-3": "euw3",<br>  "sa-east-1": "sae1",<br>  "us-east-1": "use1",<br>  "us-east-2": "use2",<br>  "us-gov-east-1": "usge1",<br>  "us-gov-west-1": "usgw1",<br>  "us-west-1": "usw1",<br>  "us-west-2": "usw2"<br>}</pre> | no |
| <a name="input_ssl_certificate_arn"></a> [ssl\_certificate\_arn](#input\_ssl\_certificate\_arn) | ARN of ACM SSL certificate | `any` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | Default CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of infra VPC | `any` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | R53 zone id for public domain | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apm_domain_name"></a> [apm\_domain\_name](#output\_apm\_domain\_name) | APM domain name |
| <a name="output_elastic_stack_bucket_name"></a> [elastic\_stack\_bucket\_name](#output\_elastic\_stack\_bucket\_name) | Name of the bucket for ELKS snapshots |
| <a name="output_elasticsearch_elastic_password"></a> [elasticsearch\_elastic\_password](#output\_elasticsearch\_elastic\_password) | Password of the superuser 'elastic' |
| <a name="output_gitlab_runner_cache_bucket_name"></a> [gitlab\_runner\_cache\_bucket\_name](#output\_gitlab\_runner\_cache\_bucket\_name) | Name of the s3 bucket for gitlab-runner cache |
| <a name="output_kibana_domain_name"></a> [kibana\_domain\_name](#output\_kibana\_domain\_name) | Kibana dashboards address |
| <a name="output_kube_prometheus_stack_alertmanager_domain_name"></a> [kube\_prometheus\_stack\_alertmanager\_domain\_name](#output\_kube\_prometheus\_stack\_alertmanager\_domain\_name) | Alertmanager ui address |
| <a name="output_kube_prometheus_stack_get_grafana_admin_password"></a> [kube\_prometheus\_stack\_get\_grafana\_admin\_password](#output\_kube\_prometheus\_stack\_get\_grafana\_admin\_password) | Command which gets admin password from kubernetes secret |
| <a name="output_kube_prometheus_stack_grafana_admin_password"></a> [kube\_prometheus\_stack\_grafana\_admin\_password](#output\_kube\_prometheus\_stack\_grafana\_admin\_password) | Grafana admin password |
| <a name="output_kube_prometheus_stack_grafana_domain_name"></a> [kube\_prometheus\_stack\_grafana\_domain\_name](#output\_kube\_prometheus\_stack\_grafana\_domain\_name) | Grafana dashboards address |
| <a name="output_kube_prometheus_stack_prometheus_domain_name"></a> [kube\_prometheus\_stack\_prometheus\_domain\_name](#output\_kube\_prometheus\_stack\_prometheus\_domain\_name) | Prometheus ui address |
| <a name="output_victoria_metrics_k8s_stack_get_grafana_admin_password"></a> [victoria\_metrics\_k8s\_stack\_get\_grafana\_admin\_password](#output\_victoria\_metrics\_k8s\_stack\_get\_grafana\_admin\_password) | Command which gets admin password from kubernetes secret |
| <a name="output_victoria_metrics_k8s_stack_grafana_admin_password"></a> [victoria\_metrics\_k8s\_stack\_grafana\_admin\_password](#output\_victoria\_metrics\_k8s\_stack\_grafana\_admin\_password) | Grafana admin password |
| <a name="output_victoria_metrics_k8s_stack_grafana_domain_name"></a> [victoria\_metrics\_k8s\_stack\_grafana\_domain\_name](#output\_victoria\_metrics\_k8s\_stack\_grafana\_domain\_name) | Grafana dashboards address |
