output "instance_id" {
  value = aws_instance.backend.id
}

output "public_ip" {
  value = aws_eip.backend.public_ip
}

output "private_ip" {
  value = aws_instance.backend.private_ip
}

output "security_group_id" {
  value = aws_security_group.ec2.id
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/id_ed25519_github ec2-user@${aws_eip.backend.public_ip}"
}