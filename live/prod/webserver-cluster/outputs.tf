#Change the below to output the DNS name of the ALB instead of the public IP

output "alb_dns_name" {
        value           = aws_lb.First_AWS_Trial.dns_name
        description     = "The domain name of the load balancer"
}
