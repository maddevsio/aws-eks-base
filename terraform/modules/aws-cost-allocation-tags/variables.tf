variable "tags" {
  type = list(object({
    tag_key = string
    status  = string
  }))
}
