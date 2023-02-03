output "applicationdns" {
    description = "DNS Name of application"
    value = "https://${var.hostname}.${var.dnsname}"
}

output "albdns" {
    description = "DNS Name of alb"
    value = aws_lb.alb.dns_name
}