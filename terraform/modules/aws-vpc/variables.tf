variable "name" {
  type = string
}
variable "single_nat_gateway" {
  type    = bool
  default = false
}
variable "cidr" {
  type = string
}
variable "azs" {
  type = list(any)
}
variable "tags" {
  type    = any
  default = {}
}
