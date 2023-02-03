# Create Load Balancer
resource "aws_lb" "alb" {
    depends_on = [aws_security_group.albsg]
    name = "alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.albsg.id]
    subnets = [var.subneta, var.subnetb]
    enable_deletion_protection = false
    enable_http2 = false
    tags = {
        Name = "${var.environment}-alb"
    }
}

# Create ALB TargetGroup for HTTP
resource "aws_lb_target_group" "albtghttp" {
    name = "albtghttp"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpcid
    #deregistration_delay = 60
    stickiness {
        type ="lb_cookie"
    }
    health_check {
      path = "/"
      port = 80
      healthy_threshold = 3
      unhealthy_threshold = 3
      timeout = 10
      interval = 30
      matcher = "200,301,302"
    }
}

# Create Security Group for Load Balancer
resource "aws_security_group" "albsg" {
    name = "albsg"
    description = "Permits web traffic to LB"
    vpc_id = var.vpcid

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.environment}-albsg"
    }
}

# Create ALB listener for HTTP
resource "aws_alb_listener" "alblhttp" {
    depends_on = [aws_lb.alb, aws_lb_target_group.albtghttp]
    load_balancer_arn = aws_lb.alb.arn
    port = 80
    protocol = "HTTP"
    
    default_action {
        target_group_arn = aws_lb_target_group.albtghttp.arn
        type = "forward"
    }
}

# Create ALB listener fot HTTPS
resource "aws_alb_listener" "alblhttps" {
    depends_on = [aws_acm_certificate.albcert]
    load_balancer_arn = aws_lb.alb.arn
    port = 443
    protocol = "HTTPS"
    certificate_arn = aws_acm_certificate.albcert.arn

    default_action {
        target_group_arn = aws_lb_target_group.albtghttp.arn
        type = "forward"
    }
}

# Associate EC2s with Target Group
resource "aws_alb_target_group_attachment" "albtghttpattach" {
    count = var.ec2servers
    target_group_arn = aws_lb_target_group.albtghttp.arn
    target_id = var.serversid[count.index]
    #target_id = aws_instance.servers[count.index].id
    port = 80
}

# Refer Route53 PublicZone
data "aws_route53_zone" "pubzone" {
    name = var.dnsname
    private_zone = false
}

# Create Route53 A LoadBalancer Record
resource "aws_route53_record" "lbarecord" {
    depends_on = [aws_lb.alb]
    zone_id = data.aws_route53_zone.pubzone.zone_id
    name = "${var.hostname}.${var.dnsname}"
    type = "A"

    alias {
        name = aws_lb.alb.dns_name
        zone_id = aws_lb.alb.zone_id
        evaluate_target_health = true
    }
}


# Create Certificate
resource "aws_acm_certificate" "albcert" {
  domain_name       = "${var.hostname}.${var.dnsname}"
  validation_method = "DNS"
  
  tags = {
    Name        = "albcert"
  }
}

# Create Route53 Certificate Record Validation
resource "aws_route53_record" "lbcertvalrec" {
    for_each = {
        for dvo in aws_acm_certificate.albcert.domain_validation_options : dvo.domain_name => {
            name = dvo.resource_record_name
            record = dvo.resource_record_value
            type = dvo.resource_record_type
        }
    }

    allow_overwrite = true
    name = each.value.name
    records = [each.value.record]
    ttl = 60
    type = each.value.type
    zone_id = data.aws_route53_zone.pubzone.zone_id
}

# Create Validation
resource "aws_acm_certificate_validation" "certvalid" {
  certificate_arn = aws_acm_certificate.albcert.arn
  validation_record_fqdns = [for record in aws_route53_record.lbcertvalrec : record.fqdn]
}