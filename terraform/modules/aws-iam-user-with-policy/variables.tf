variable "name" {
  type        = string
  description = "Project name, required to form unique resource names"
}

variable "policy" {
  type        = string
  description = "IAM policy that will be attached to user"
}
