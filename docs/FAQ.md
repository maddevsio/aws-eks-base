# Table of content

<!-- TOC -->
  * [EKS Upgrading](#eks-upgrading)
  * [K8S namespace features:](#k8s-namespace-features-)
  * [Gitlab-runner](#gitlab-runner)
    * [How to add more restrictions for Gitlab-Runner](#how-to-add-more-restrictions-for-gitlab-runner)
  * [Monitoring](#monitoring)
  * [Grafana: How to add GitHub/Gitlab OAuth2 Authentication:](#grafana--how-to-add-githubgitlab-oauth2-authentication-)
  * [Alertmanager](#alertmanager)
    * [If you want to receive alerts **via Slack**, then do next:](#if-you-want-to-receive-alerts-via-slack--then-do-next-)
  * [Deleting Tigera-operator](#deleting-tigera-operator)
  * [What if you don't want to use an aws-load-balancer controller in front of an ingress-nginx and want to use a cert-manager and terminate SSL on ingres-nginx side](#what-if-you-dont-want-to-use-an-aws-load-balancer-controller-in-front-of-an-ingress-nginx-and-want-to-use-a-cert-manager-and-terminate-ssl-on-ingres-nginx-side)
  * [Apply using terraform](#apply-using-terraform)
    * [S3 state backend](#s3-state-backend)
      * [Inputs](#inputs)
      * [init](#init)
      * [plan](#plan)
      * [apply](#apply)
  * [Update terraform version](#update-terraform-version)
  * [Update terraform providers](#update-terraform-providers)
  * [Update terragrunt version](#update-terragrunt-version)
<!-- TOC -->

## EKS Upgrading
To upgrade k8s cluster to a new version, please use [official guide](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html) and check changelog/breaking changes.
Starting from v1.18 EKS supports K8S add-ons. We use them to update things like vpc-cni, kube-proxy, coredns. To get the latest add-ons versions, run:
```bash
aws eks describe-addon-versions --kubernetes-version 1.21 --query 'addons[].[addonName, addonVersions[0].addonVersion]'
```
where `1.21` - is a k8s version on which we are updating.
DO NOT FORGET!!! to update cluster-autoscaler too. Its version must be the same as the cluster version.
Also ***IT'S VERY RECOMMENDED*** to check that deployed objects have actual apiVersions that won't be deleted after upgrading. There is a tool [*pluto*](https://github.com/FairwindsOps/pluto) that can help to do it.
```bash
Switch to the correct cluster
Run `pluto detect-helm -o markdown --target-versions k8s=v1.22.0`, where `k8s=v1.22.0` is a k8s version we want to update to.
```

## K8S namespace features:
We strongly recommend using our terraform module `kubernetes-namespace` to manage (create) k8s namespaces. It provides additional functionalities.
* **LimitRange**: By default, containers run with unbounded compute resources on a Kubernetes cluster. This module has a policy [**LimitRange**](https://kubernetes.io/docs/concepts/policy/limit-range/) to constrain resource allocations (to Pods or Containers) in a namespace. Default value is:
```
    {
      type = "Container"
      default = {
        cpu    = "150m"
        memory = "128Mi"
      }
      default_request = {
        cpu    = "100m"
        memory = "64Mi"
      }
    }
```
If you don't specify requests or limits for containers these default values will be applied.

* **ResourceQuota**: When several users or teams share a cluster with a fixed number of nodes, there is a concern that one team could use more than its fair share of resources. Using this module you can define [**ResourceQuota**](https://kubernetes.io/docs/concepts/policy/resource-quotas/) to provide constraints that limit aggregate resource consumption per namespace. It can limit the quantity of objects that can be created in a namespace by type, as well as the total amount of compute resources that may be consumed by resources in that namespace. Default value is empty (No any resource quotas)

* **NetworkPolicy**: If you want to control traffic flow at the IP address or port level (OSI layer 3 or 4), then you might consider using Kubernetes NetworkPolicies for particular applications in your cluster. [**NetworkPolicies**](https://kubernetes.io/docs/concepts/services-networking/network-policies/) are an application-centric construct which allow you to specify how a pod is allowed to communicate with various network "entities" (we use the word "entity" here to avoid overloading the more common terms such as "endpoints" and "services", which have specific Kubernetes connotations) over the network.

The entities that a Pod can communicate with are identified through a combination of the following 3 identifiers:

Other pods that are allowed (exception: a pod cannot block access to itself)
Namespaces that are allowed
IP blocks (exception: traffic to and from the node where a Pod is running is always allowed, regardless of the IP address of the Pod or the node)
Default value is empty (No any NetworkPolicies - all traffic is allowed)

Example of configuring namespace LimitRange, ResourceQuota and NetworkPolicy:
```
module "test_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "test"
  limits = [
    {
      type = "Container"
      default = {
        cpu    = "200m"
        memory = "64Mi"
      }
      default_request = {
        cpu    = "100m"
        memory = "32Mi"
      }
      max = {
        cpu = "2"
      }
    },
    {
      type = "Pod"
      max = {
        cpu = "4"
      }
    }
  ]
  resource_quotas = [
    {
      name = "compute-resources"
      hard = {
        "requests.cpu"    = 1
        "requests.memory" = "1Gi"
        "limits.cpu"      = 2
        "limits.memory"   = "2Gi"
      }
      scope_selector = {
        scope_name = "PriorityClass"
        operator   = "NotIn"
        values     = ["high"]
      }
    },
    {
      name = "object-counts"
      hard = {
        configmaps               = 10
        persistentvolumeclaims   = 4
        pods                     = 4
        replicationcontrollers   = 20
        secrets                  = 10
        services                 = 10
        "services.loadbalancers" = 2
      }
    }
  ]
  network_policies = [
    {
      name         = "allow-this-namespace"
      policy_types = ["Ingress"]
      pod_selector = {}
      ingress = {
        from = [
          {
            namespace_selector = {
              match_labels = {
                name = "test"
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-from-ingress-namespace"
      policy_types = ["Ingress"]
      pod_selector = {}
      ingress = {
        from = [
          {
            namespace_selector = {
              match_labels = {
                name = "ing"
              }
            }
          }
        ]
      }
    },
    {
      name        = "allow-egress-to-dev"
      policy_type = ["Egress"]
      pod_selector = {}
      egress = {
        ports = [
          {
            port     = "80"
            protocol = "TCP"
          }
        ]
        to = [
          {
            namespace_selector = {
              match_labels = {
                name = "dev"
              }
            }
          }
        ]
      }
    }
  ]
}
```

## Gitlab-runner
Gitlab-runner installation requieres `registration token`.
* How to generate token see [here](https://docs.gitlab.com/runner/register/#requirements).
* Set `gitlab_runner_registration_token` variable in [AWS Secrets Manager](https://console.aws.amazon.com/secretsmanager/home?region=us-east-1#!/home) secret with the pattern `/${local.name_wo_region}/infra/layer2-k8s`.

### How to add more restrictions for Gitlab-Runner
By default Gitlab-Runner can deploy into any namespaces. If you want to allow Gitlab-Runner to deploy only into specific namespaces, then do these:
* Create new Service Account:
```
resource "kubernetes_service_account" "gitlab_runner" {
  metadata {
    name      = "my-gitlab-runner-executor-sa"
    namespace = module.gitlab_runner_namespace.name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.aws_iam_gitlab_runner.role_arn
    }
  }
  automount_service_account_token = true
}
```
* Create a new Kubernetes Role and RoleBinding. For example, these role and rolebinding will allow to deploy into dev namespace only:
```
resource "kubernetes_role" "dev" {
  metadata {
    name      = "${local.name}-dev"
    namespace = "dev"
  }

  rule {
    api_groups = ["", "apps", "extensions", "batch", "networking.k8s.io", "kubernetes-client.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "dev" {
  metadata {
    name      = "${local.name}-dev"
    namespace = "dev"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.dev.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.gitlab_runner.metadata.0.name
    namespace = module.gitlab_runner_namespace.name
  }
}
```
* Set the name of a new created account in layer2-k8s/templates/gitlab-runner-values.yaml
```
...
runners:
...
      [runners.kubernetes]
        ...
        image = "public.ecr.aws/ubuntu/ubuntu:20.04"
        service_account = "my-gitlab-runner-executor-sa"
        ...
...
```
* Disable cluster-wide access for the default Service Account:
```
...
rbac:
  clusterWideAccess: false
...
```

## Monitoring
This boilerplate provides two solutions for monitoring:
1. VictoriaMetrics based on [victoria-metrics-k8s-stack](https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-k8s-stack)
2. Prometheus based on [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

VictoriaMetrics is installed by default. However, you can easily switch to Prometheus just **enabling** it and **disabling** VictoriaMetrics in `terraform/layer2-k8s/helm-releases.yaml`. You need to do it before the first apply of the layer2-k8s.
VictoriaMetrics Operator supports several [Prometheus objects](https://github.com/VictoriaMetrics/operator#overview). For example, Servicemonitor, PrometheusRule. However, we need to somehow install necessary Prometheus CRDs in a k8s cluster. So, it's done in the `eks-prometheus-operator-crds.tf` file, where we install Prometheus' CRDs separately from kube-prometheus-stack.

## Grafana: How to add GitHub/Gitlab OAuth2 Authentication:
By default we install Grafana without integrating it with GitHub or Gitlab and use basic authentication (login/password). If you want to integrate it to use OAuth2, then do next:
1. Set `grafana_oauth_type` variable in the `terraform/layer2-k8s/eks-victoria-metrics-k8s-stack.tf` or `terraform/layer2-k8s/eks-kube-prometheus-stack.tf` to the desired value (github or gitlab).
2. **Gitlab**:
   * See [this instruction](https://grafana.com/docs/grafana/latest/auth/gitlab/#gitlab-oauth2-authentication) and generate necessary tokens.
   * Set `grafana_gitlab_client_id`, `grafana_gitlab_client_secret`, `grafana_gitlab_group` variables in [AWS Secrets Manager](https://console.aws.amazon.com/secretsmanager/home?region=us-east-1#!/home) secret with the pattern `/${local.name_wo_region}/infra/layer2-k8s`.
3. **GitHub**:
   * See [this instruction](https://grafana.com/docs/grafana/latest/auth/github/#github-oauth2-authentication) and generate necessary tokens.
   * Set `grafana_github_client_id`, `grafana_github_client_secret`, `grafana_github_team_ids`, `grafana_github_allowed_organizations` variables in [AWS Secrets Manager](https://console.aws.amazon.com/secretsmanager/home?region=us-east-1#!/home) secret with the pattern `/${local.name_wo_region}/infra/layer2-k8s`.

## Alertmanager
Alertmanager is disabled in default installation. If you want to enable it, then do next:
1. VictoriaMetrics:
   Open file layer2-k8s/eks-victoria-metrics-k8s-stack.tf and change:

    ```yaml
    locals {
    ....
      victoria_metrics_k8s_stack_alertmanager_values         = <<VALUES
    # Alertmanager parameters
    alertmanager:
      enabled: false
    ....
    }

    to

    locals {
    ....
      victoria_metrics_k8s_stack_alertmanager_values         = <<VALUES
    # Alertmanager parameters
    alertmanager:
      enabled: true
    ....
    }
    ```

2. Prometheus:
   Open file layer2-k8s/eks-kube-prometheus-stack.tf and change:

    ```yaml
    locals {
    ....
      kube_prometheus_stack_alertmanager_values         = <<VALUES
    # Alertmanager parameters
    alertmanager:
      enabled: false
    ....
    }

    to

    locals {
    ....
      kube_prometheus_stack_alertmanager_values         = <<VALUES
    # Alertmanager parameters
    alertmanager:
      enabled: true
    ....
    }
    ```

### If you want to receive alerts **via Slack**, then do next:
* See [this instruction](https://slack.com/help/articles/115005265063-Incoming-webhooks-for-Slack) and generate Slack Incoming Webhook
* Set `alertmanager_slack_webhook`, `alertmanager_slack_channel` variables in [AWS Secrets Manager](https://console.aws.amazon.com/secretsmanager/home?region=us-east-1#!/home) secret with the pattern `/${local.name_wo_region}/infra/layer2-k8s`.

## Deleting Tigera-operator
1. Run:

    ```bash
    $ kubectl delete installations.operator.tigera.io default
    ```

2. Set `enabled: false` for `id: tigera-operator` in the file **helm-releases.yaml**
3. Run `terraform apply` in the layer2-k8s folder
4. Run:

    ```bash
    $ kubectl delete ns calico-apiserver calico-system
    ```
5. Restart all nodes

## What if you don't want to use an aws-load-balancer controller in front of an ingress-nginx and want to use a cert-manager and terminate SSL on ingres-nginx side

1. Set `nginx ` for a `nginx_ingress_ssl_terminator` variable in the layer2-k8s folder
2. Set `enabled: false` for `id: aws-load-balancer-controller` in the **layer2-k8s/helm-releases.yaml** file
3. Set `enabled: true` for `id: external-dns`, `id: cert-manager`, `id: cert-mananger-certificate`, `id:cert-manager-cluster-issuer` in the **layer2-k8s/helm-releases.yaml** file
4. Run `terraform apply` in the layer2-k8s folder

## Apply using terraform

### S3 state backend

By default, you can use local state for this project, but we suggest you to use S3 backend.

<details>
  <summary>S3 bucket for remote state</summary>

  Set `STATE_BUCKET_NAME` and `STATE_BUCKET_REGION`, then create S3 bucket:

  ```bash
  $ aws s3api create-bucket \
    --bucket $STATE_BUCKET_NAME \
    --region $STATE_BUCKET_REGION \
    --create-bucket-configuration LocationConstraint=$STATE_BUCKET_REGION
  ```

And add versioning:

  ```bash
  $ aws s3api put-bucket-versioning \
    --bucket $STATE_BUCKET_NAME \
    --region $STATE_BUCKET_REGION \
    --versioning-configuration Status=Enabled
  ```

  Create backend configuration for each layer:

  ```bash
  $ cat <<EOF > terraform/layer1-aws/backend.tf
  terraform {
    backend "s3" {
      bucket  = "$STATE_BUCKET_NAME"
      encrypt = true
      key     = "layer1-aws/terraform.tfstate"
      region  = "$STATE_BUCKET_REGION"
    }
  }
  EOF

  $ cat <<EOF > terraform/layer2-k8s/backend.tf
  terraform {
    backend "s3" {
      bucket  = "$STATE_BUCKET_NAME"
      encrypt = true
      key     = "layer2-k8s/terraform.tfstate"
      region  = "$STATE_BUCKET_REGION"
    }
  }
  EOF
  ```
</details>

#### Inputs

You can find demo.tfvars.example file in each layer.
File `terraform/layer1-aws/demo.tfvars.example` contains dummy values. Copy this file to `terraform/layer1-aws/terraform.tfvars` and set you values:

```bash
$ cp terraform/layer1-aws/demo.tfvars.example terraform/layer1-aws/terraform.tfvars
```

Previously we used `data "terraform_remote_state"` in order to get some necessary attributes from layer1 state. But
we decided to decouple layers in order to make it possible to use them separately. Values for necessary variables
will be ready after applying layer1, put them as inputs for layer2

```bash
$ cp terraform/layer2-k8s/demo.tfvars.example terraform/layer2-k8s/terraform.tfvars
```

> You can find all possible variables in each layer's Readme.

#### init

The `terraform init` command is used to initialize the state and its backend, downloads providers, plugins, and modules. This is the first command to be executed in `layer1` and `layer2`:

  ```bash
  $ terraform init
  ```

  Correct output:

  ```
  * provider.aws: version = "~> 2.10"
  * provider.local: version = "~> 1.2"
  * provider.null: version = "~> 2.1"
  * provider.random: version = "~> 2.1"
  * provider.template: version = "~> 2.1"

  Terraform has been successfully initialized!
  ```

#### plan

The `terraform plan` command reads terraform state and configuration files and displays a list of changes and actions that need to be performed to bring the state in line with the configuration. It's a convenient way to test changes before applying them. When used with the `-out` parameter, it saves a batch of changes to a specified file that can later be used with `terraform apply`. Call example:

  ```bash
  $ terraform plan
  # ~600 rows skipped
  Plan: 82 to add, 0 to change, 0 to destroy.

  ------------------------------------------------------------------------

  Note: You didn't specify an "-out" parameter to save this plan, so Terraform
  can't guarantee that exactly these actions will be performed if
  "terraform apply" is subsequently run.
  ```

#### apply

The `terraform apply` command scans `.tf` in the current directory and brings the state to the configuration described in them by making changes in the infrastructure. By default, `plan` with a continuation dialog is performed before applying. Optionally, you can specify a saved plan file as input:

  ```bash
  $ terraform apply
  # ~600 rows skipped
  Plan: 82 to add, 0 to change, 0 to destroy.

  Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value: yes

  Apply complete! Resources: 82 added, 0 changed, 0 destroyed.
  ```

We do not always need to re-read and compare the entire state if small changes have been added that do not affect the entire infrastructure. For this, you can use targeted `apply`; for example:

  ```bash
  $ terraform apply -target helm_release.kibana
  ```

Details can be found [here](https://www.terraform.io/docs/cli/run/index.html)

> The first time, the `apply` command must be executed in the layers in order: first layer1, then layer2. Infrastructure `destroy` should be done in the reverse order.

## Update terraform version

Change terraform version in this files

* `terraform/.terraform-version` - the main terraform version for tfenv tool
* `.github/workflows/terraform-ci.yml` - the terraform version for github actions need for `terraform-validate` and
`terraform-format`.
* `terraform/layer1-aws/main.tf`
* `terraform/layer2-k8s/main.tf`

## Update terraform providers

Change terraform providers version in this files

* `terraform/layer1-aws/main.tf`
* `terraform/layer2-k8s/main.tf`

When we changed terraform provider versions, we need to update terraform state. For update terraform state in layers we need to run this command:

```
terraform init -upgrade
```

## Update terragrunt version

Set version in two files:

* `terragrunt/.terragrunt-version` - version for `tgenv`
* `terragrnt/terragrunt.hcl`
