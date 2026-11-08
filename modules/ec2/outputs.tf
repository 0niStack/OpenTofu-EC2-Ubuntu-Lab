output "instance_ids" {
  value = aws_instance.this[*].id
}

output "names" {
  value = aws_instance.this[*].tags.Name
}

output "public_ips" {
  value = aws_instance.this[*].public_ip
}

output "ami_id" {
  value = var.ami_id
}
