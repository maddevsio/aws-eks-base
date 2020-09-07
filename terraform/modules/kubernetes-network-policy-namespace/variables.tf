variable "namespace" {
  type        = string
  description = "Namespace name"
}

variable "allow_from_namespaces" {
  type        = list(string)
  description = "List of namespaces to allow trafic from."
}

variable "depends" {
  type        = any
  default     = null
  description = "Indicates the resource this resource depends on."
}
