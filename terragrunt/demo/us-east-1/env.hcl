locals {
  values = merge(
    yamldecode(file(find_in_parent_folders("region.yaml"))),
    yamldecode(file("env.yaml"))
  )
}

inputs = local.values
