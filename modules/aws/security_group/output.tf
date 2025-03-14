output "sg_id" {
  value = { for k, sg in aws_security_group.this : k => sg.id }
}