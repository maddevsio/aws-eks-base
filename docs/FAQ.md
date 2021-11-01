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
* By default, containers run with unbounded compute resources on a Kubernetes cluster. This module has a policy [**LimitRange**](https://kubernetes.io/docs/concepts/policy/limit-range/) to constrain resource allocations (to Pods or Containers) in a namespace. Default value is:
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

* When several users or teams share a cluster with a fixed number of nodes, there is a concern that one team could use more than its fair share of resources. Using this module you can define [**ResourceQuota**](https://kubernetes.io/docs/concepts/policy/resource-quotas/) to provide constraints that limit aggregate resource consumption per namespace. It can limit the quantity of objects that can be created in a namespace by type, as well as the total amount of compute resources that may be consumed by resources in that namespace. Default value is empty (No any resource quotas)

Example of configuring namespace LimitRange and ResourceQuota:
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
}
```

