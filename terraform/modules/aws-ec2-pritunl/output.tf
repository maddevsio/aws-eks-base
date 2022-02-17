output "pritunl_endpoint" {
  value = aws_eip.this.public_ip
}
output "pritunl_security_group" {
  value = module.ec2_sg.security_group_id
}
