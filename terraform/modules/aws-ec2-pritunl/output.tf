output "pritunl_endpoint" {
  value = aws_eip.this.id
}
output "pritunl_security_group" {
  value = module.ec2_sg.this_security_group_id
}
