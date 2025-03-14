output "instance_id" {
  value = { for k, instance in aws_instance.this : k => instance.id }
}

output "instance_arn" {
  value = { for k, instance in aws_instance.this : k => instance.arn }
}

output "public_ip" {
  value = { for k, instance in aws_instance.this : k => instance.public_ip }
}