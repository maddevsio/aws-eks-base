output "private_key_pem" {
  value       = tls_private_key.this.private_key_pem
  description = ""
}

output "cert_pem" {
  value       = tls_self_signed_cert.this.cert_pem
  description = ""
}

output "p8" {
  value       = data.external.this_p8.result["p8"]
  description = ""
}
