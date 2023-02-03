output "ec2sgid" {
    value = aws_security_group.ec2sg.id
}

output "servers" {
    value = var.ec2servers
}

output "serversid" {
    value = aws_instance.servers.*.id
}

output "serverpubdns" {
    value = aws_instance.servers.*.public_dns
}

output "serverprivip" {
    value = aws_instance.servers.*.private_ip
}