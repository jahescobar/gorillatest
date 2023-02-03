output "applicationdns" {
    description = "DNS Name of application"
    value = module.loadbalancer.applicationdns
}

output "albdns" {
    description = "DNS Name of alb"
    value = module.loadbalancer.albdns
}