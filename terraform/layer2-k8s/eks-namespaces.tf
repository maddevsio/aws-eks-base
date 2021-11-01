module "dns_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "dns"
}

module "ing_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "ing"
}

module "elk_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "elk"
}

module "prod_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "prod"
}

module "staging_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "staging"
}

module "dev_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "dev"
}

module "fargate_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "fargate"
}

module "ci_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "ci"
}

module "sys_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "sys"
}

module "monitoring_namespace" {
  source = "../modules/kubernetes-namespace"
  name   = "monitoring"
}
