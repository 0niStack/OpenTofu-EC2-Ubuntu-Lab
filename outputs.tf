output "instances" {
  description = "Name => public IP"
  value       = zipmap(module.ec2.names, module.ec2.public_ips)
}

output "instance_ids" {
  value = module.ec2.instance_ids
}

output "ami_id" {
  value = module.ec2.ami_id
}

output "security_group_id" {
  value = module.security_group.id
}

output "ssh_commands" {
  description = "SSH command per VM (adjust the private key path if needed)"
  value = [
    for name, ip in zipmap(module.ec2.names, module.ec2.public_ips) :
    "ssh -i ~/.ssh/id_ed25519 ubuntu@${ip}  # ${name}"
  ]
}
