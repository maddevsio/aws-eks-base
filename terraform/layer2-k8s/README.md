<!-- BEGIN_TF_DOCS -->
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
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.2 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_iam_autoscaler"></a> [aws\_iam\_autoscaler](#module\_aws\_iam\_autoscaler) | ../modules/aws-iam-eks-trusted | n/a |
| <a name="module_aws_iam_aws_loadbalancer_controller"></a> [aws\_iam\_aws\_loadbalancer\_controller](#module\_aws\_iam\_aws\_loadbalancer\_controller) | ../modules/aws-iam-eks-trusted | n/a |
| <a name="module_aws_iam_cert_manager"></a> [aws\_iam\_cert\_manager](#module\_aws\_iam\_cert\_manager) | ../modules/aws-iam-eks-trusted | n/a |
| <a name="module_aws_iam_elastic_stack"></a> [aws\_iam\_elastic\_stack](#module\_aws\_iam\_elastic\_stack) | ../modules/aws-iam-user-with-policy | n/a |
| <a name="module_aws_iam_external_dns"></a> [aws\_iam\_external\_dns](#module\_aws\_iam\_external\_dns) | ../modules/aws-iam-eks-trusted | n/a |
| <a name="module_aws_iam_external_secrets"></a> [aws\_iam\_external\_secrets](#module\_aws\_iam\_external\_secrets) | ../modules/aws-iam-eks-trusted | n/a |
| <a name="module_aws_iam_gitlab_runner"></a> [aws\_iam\_gitlab\_runner](#module\_aws\_iam\_gitlab\_runner) | ../modules/aws-iam-eks-trusted | n/a |
| <a name="module_aws_iam_kube_prometheus_stack_grafana"></a> [aws\_iam\_kube\_prometheus\_stack\_grafana](#module\_aws\_iam\_kube\_prometheus\_stack\_grafana) | ../modules/aws-iam-eks-trusted | n/a |
| <a name="module_aws_iam_victoria_metrics_k8s_stack_grafana"></a> [aws\_iam\_victoria\_metrics\_k8s\_stack\_grafana](#module\_aws\_iam\_victoria\_metrics\_k8s\_stack\_grafana) | ../modules/aws-iam-eks-trusted | n/a |
| <a name="module_aws_load_balancer_controller_namespace"></a> [aws\_load\_balancer\_controller\_namespace](#module\_aws\_load\_balancer\_controller\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_aws_node_termination_handler_namespace"></a> [aws\_node\_termination\_handler\_namespace](#module\_aws\_node\_termination\_handler\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_certmanager_namespace"></a> [certmanager\_namespace](#module\_certmanager\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_cluster_autoscaler_namespace"></a> [cluster\_autoscaler\_namespace](#module\_cluster\_autoscaler\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_elastic_tls"></a> [elastic\_tls](#module\_elastic\_tls) | ../modules/self-signed-certificate | n/a |
| <a name="module_elk_namespace"></a> [elk\_namespace](#module\_elk\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_external_dns_namespace"></a> [external\_dns\_namespace](#module\_external\_dns\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_external_secrets_namespace"></a> [external\_secrets\_namespace](#module\_external\_secrets\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_fargate_namespace"></a> [fargate\_namespace](#module\_fargate\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_gitlab_runner_namespace"></a> [gitlab\_runner\_namespace](#module\_gitlab\_runner\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_ingress_nginx_namespace"></a> [ingress\_nginx\_namespace](#module\_ingress\_nginx\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_istio_system_namespace"></a> [istio\_system\_namespace](#module\_istio\_system\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_keda_namespace"></a> [keda\_namespace](#module\_keda\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_kiali_namespace"></a> [kiali\_namespace](#module\_kiali\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_kube_prometheus_stack_namespace"></a> [kube\_prometheus\_stack\_namespace](#module\_kube\_prometheus\_stack\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_loki_namespace"></a> [loki\_namespace](#module\_loki\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_reloader_namespace"></a> [reloader\_namespace](#module\_reloader\_namespace) | ../modules/kubernetes-namespace | n/a |
| <a name="module_victoria_metrics_k8s_stack_namespace"></a> [victoria\_metrics\_k8s\_stack\_namespace](#module\_victoria\_metrics\_k8s\_stack\_namespace) | ../modules/kubernetes-namespace | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.elastic_stack](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.gitlab_runner_cache](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.elastic_stack_public_access_block](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.gitlab_runner_cache_public_access_block](https://registry.terraform.io/providers/aws/4.10.0/docs/resources/s3_bucket_public_access_block) | resource |
| [helm_release.aws_loadbalancer_controller](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.aws_node_termination_handler](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [helm_release.calico_daemonset](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
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
| [helm_release.victoria_metrics_k8s_stack](https://registry.terraform.io/providers/helm/2.5.1/docs/resources/release) | resource |
| [kubectl_manifest.istio_prometheus_service_monitor_cp](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.istio_prometheus_service_monitor_dp](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.kube_prometheus_stack_operator_crds](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
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
| [aws_caller_identity.current](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.main](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.main](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/eks_cluster_auth) | data source |
| [aws_secretsmanager_secret.infra](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.infra](https://registry.terraform.io/providers/aws/4.10.0/docs/data-sources/secretsmanager_secret_version) | data source |
| [http_http.kube_prometheus_stack_operator_crds](https://registry.terraform.io/providers/hashicorp/http/2.1.0/docs/data-sources/http) | data source |
| [terraform_remote_state.layer1-aws](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_allowed_ips"></a> [additional\_allowed\_ips](#input\_additional\_allowed\_ips) | IP addresses allowed to connect to private resources | `list(any)` | `[]` | no |
| <a name="input_allowed_account_ids"></a> [allowed\_account\_ids](#input\_allowed\_account\_ids) | List of allowed AWS account IDs | `list` | `[]` | no |
| <a name="input_cluster_autoscaler_version"></a> [cluster\_autoscaler\_version](#input\_cluster\_autoscaler\_version) | Version of cluster autoscaler | `string` | `"v1.21.0"` | no |
| <a name="input_helm_release_history_size"></a> [helm\_release\_history\_size](#input\_helm\_release\_history\_size) | How much helm releases to store | `number` | `5` | no |
| <a name="input_nginx_ingress_ssl_terminator"></a> [nginx\_ingress\_ssl\_terminator](#input\_nginx\_ingress\_ssl\_terminator) | Select SSL termination type | `string` | `"lb"` | no |
| <a name="input_region"></a> [region](#input\_region) | Default infrastructure region | `string` | `"us-east-1"` | no |
| <a name="input_remote_state_bucket"></a> [remote\_state\_bucket](#input\_remote\_state\_bucket) | Name of the bucket for terraform state | `string` | n/a | yes |
| <a name="input_remote_state_key"></a> [remote\_state\_key](#input\_remote\_state\_key) | Key of the remote state for terraform\_remote\_state | `string` | `"layer1-aws"` | no |

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
<!-- END_TF_DOCS -->