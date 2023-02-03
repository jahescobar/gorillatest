output "dns_endpoint" {
    value = "http://${aws_elastic_beanstalk_environment.ebenv.endpoint_url}/"
}

output "elastic_beanstalk_environment_cname" {
  value       = aws_elastic_beanstalk_environment.ebenv.cname
  description = "Environment cname"
}

#output "ebvpcid" {
#    value = aws_vpc.ebvpc.id
#}

#output "ebsnpub1id" {
#    value = aws_subnet.ebsnpub1.id
#}

#output "ebsnpub2id" {
#    value = aws_subnet.ebsnpub1.id
#}