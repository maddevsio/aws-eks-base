output "pritunl_endpoint" {
  value = aws_eip.this.id
}
output "pritunl_security_group" {
  value = aws_security_group.this.id
}
