variable "annotations" {
  type        = map(any)
  default     = {}
  description = "An unstructured key value map stored with the namespace that may be used to store arbitrary metadata"
}

variable "labels" {
  type        = map(any)
  default     = {}
  description = "Map of string keys and values that can be used to organize and categorize (scope and select) namespaces."
}

variable "name" {
  type        = string
  description = "Name of the namespace, must be unique. Cannot be updated."
}

variable "depends" {
  type        = any
  default     = null
  description = "Indicates the resource this resource depends on."
}

variable "enable" {
  type        = bool
  default     = true
  description = "If set to true, create namespace"
}

variable "limits" {
  type = any
  default = [
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
  ]
}

variable "resource_quotas" {
  type    = any
  default = []
}

variable "network_policies" {
  type    = any
  default = []
}
