resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "this" {
  key_algorithm         = tls_private_key.this.algorithm
  private_key_pem       = tls_private_key.this.private_key_pem
  validity_period_hours = var.validity_period_hours
  early_renewal_hours   = var.early_renewal_hours
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
  dns_names = var.dns_names
  subject {
    common_name  = var.common_name
    organization = var.name
  }
}

data "external" "this_p8" {
  program = ["bash", "${path.module}/data-sources/p8.sh"]

  query = {
    private_key_pem = "${tls_private_key.this.private_key_pem}"
  }
}
