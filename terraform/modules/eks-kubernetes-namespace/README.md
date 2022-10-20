<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name                                                                   | Version |
| ---------------------------------------------------------------------- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [kubernetes_limit_range.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/limit_range)       | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace)           | resource |
| [kubernetes_network_policy.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_resource_quota.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/resource_quota) | resource |

## Inputs

| Name                                                                                 | Description                                                                                              | Type       | Default                                                                                                                                                                                                                             | Required |
| ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_annotations"></a> [annotations](#input\_annotations)                  | An unstructured key value map stored with the namespace that may be used to store arbitrary metadata     | `map(any)` | `{}`                                                                                                                                                                                                                                |    no    |
| <a name="input_depends"></a> [depends](#input\_depends)                              | Indicates the resource this resource depends on.                                                         | `any`      | `null`                                                                                                                                                                                                                              |    no    |
| <a name="input_enable"></a> [enable](#input\_enable)                                 | If set to true, create namespace                                                                         | `bool`     | `true`                                                                                                                                                                                                                              |    no    |
| <a name="input_labels"></a> [labels](#input\_labels)                                 | Map of string keys and values that can be used to organize and categorize (scope and select) namespaces. | `map(any)` | `{}`                                                                                                                                                                                                                                |    no    |
| <a name="input_limits"></a> [limits](#input\_limits)                                 | n/a                                                                                                      | `any`      | <pre>[<br>  {<br>    "default": {<br>      "cpu": "150m",<br>      "memory": "128Mi"<br>    },<br>    "default_request": {<br>      "cpu": "100m",<br>      "memory": "64Mi"<br>    },<br>    "type": "Container"<br>  }<br>]</pre> |    no    |
| <a name="input_name"></a> [name](#input\_name)                                       | Name of the namespace, must be unique. Cannot be updated.                                                | `string`   | n/a                                                                                                                                                                                                                                 |   yes    |
| <a name="input_network_policies"></a> [network\_policies](#input\_network\_policies) | n/a                                                                                                      | `any`      | `[]`                                                                                                                                                                                                                                |    no    |
| <a name="input_resource_quotas"></a> [resource\_quotas](#input\_resource\_quotas)    | n/a                                                                                                      | `any`      | `[]`                                                                                                                                                                                                                                |    no    |

## Outputs

| Name                                                                    | Description                                              |
| ----------------------------------------------------------------------- | -------------------------------------------------------- |
| <a name="output_labels_name"></a> [labels\_name](#output\_labels\_name) | The value of the name label                              |
| <a name="output_name"></a> [name](#output\_name)                        | The name of the created namespace (from object metadata) |
<!-- END_TF_DOCS -->



# More details about using this module can be found [here](../../../docs/FAQ.md#k8s-namespace-features)
