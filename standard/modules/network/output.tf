output "vpc" {
    value = aws_vpc.vpc.id
}

output "subneta" {
    value = aws_subnet.snpuba.id
}

output "subnetb" {
    value = aws_subnet.snpubb.id
}

output "subnetc" {
    value = aws_subnet.snpriva.id
}

output "subnetd" {
    value = aws_subnet.snprivb.id
}