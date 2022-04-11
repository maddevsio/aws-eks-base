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
   Open file layer2-k8s/eks-victoria-metrics-k8s-stack.tf and change :
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
   Open file layer2-k8s/eks-kube-prometheus-stack.tf and change :
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
