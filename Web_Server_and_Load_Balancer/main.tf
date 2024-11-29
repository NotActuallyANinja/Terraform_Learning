provider "aws" {
	region = "eu-west-1"
}

#Define data sources for existing AWS resources

data "aws_subnets" "default" {
        filter {
                name    = "vpc-id"
                values  = [data.aws_vpc.default.id]
                }
}

data "aws_vpc" "default" {
	default = true
}

#Defining the port as a variable means I am not repeating myself by having 8080 manually typed in when it needs to be r>#Also reduces effort typing in 8080 each time I deploy the EC2 instance

variable "server_port" {
        description     = "The port the server will use for http requests"
        type            = number
        default         = 8080
}

#Defining the security groups (networking resources)

resource "aws_security_group" "instance" {
        name = "terraform-example-instance"

        ingress {
                from_port       = var.server_port
                to_port         = var.server_port
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]
        }
}

#Allow inbound and outbound HTTP requests by creating security group for the load balancer

resource "aws_security_group" "alb" {
        name = "terraform-example-alb"

        ingress {
                from_port       = 80
                to_port         = 80
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]
        }

        egress {
                from_port       = 0
                to_port         = 0
                protocol        = "-1"
                cidr_blocks     = ["0.0.0.0/0"]
        }
}

#Define compute resources
#I am using a free tier EC2 instance within my region

resource "aws_launch_template" "First_AWS_Trial" {
	name			= "First_AWS_Trial_Launch_Template"
	image_id		= "ami-0be8b3ed4febc3ec0"
	instance_type		= "t2.micro"	

	user_data = base64encode(<<-EOF
		#!/bin/bash
		echo "Hello, World" > index.html
		nohup busybox httpd -f -p ${var.server_port} &
	EOF
	)

	network_interfaces {
		security_groups = [aws_security_group.instance.id]
	}
	
	tag_specifications {
		resource_type	= "instance"
		tags = {
			Name = "terraform-instance"
		}
	}	
}

#Setting the scaling rules for the group

resource "aws_autoscaling_group" "First_AWS_Trial" {
	launch_template	{
		id	= aws_launch_template.First_AWS_Trial.id
		version	= "$Latest"
	}

	vpc_zone_identifier	= data.aws_subnets.default.ids
	target_group_arns = [aws_lb_target_group.asg.arn]
	health_check_type = "ELB"

	min_size = 2
	max_size = 10

	tag {
		key			= "Name"
		value			= "terraform-asg-example"
		propagate_at_launch	= true
	}

        #Ensures that new resources are created before old ones are destroyed. This minimizes downtime during updates, particularly for critical resources
        lifecycle {
                create_before_destroy = true
        }
}

#Define load balancer resources
#Create an application load balancer

resource "aws_lb" "First_AWS_Trial" {
	name			= "terraform-asg-example"
	load_balancer_type	= "application"
	subnets			= data.aws_subnets.default.ids
	security_groups         = [aws_security_group.alb.id]
}

#Define a listener for the ALB

resource "aws_lb_listener" "http" {
	load_balancer_arn	= aws_lb.First_AWS_Trial.arn
	port			= 80
	protocol		= "HTTP"

	default_action {
		type = "fixed-response"

		fixed_response {
			content_type	= "text/plain"
			message_body	= "404: page not found"
			status_code	= 404
		}
	}
}

#Tell aws_lb to use the security group

resource "aws_lb_target_group" "asg" {
	name		= "terraform-asg-example"
	port		= var.server_port
	protocol	= "HTTP"
	vpc_id		= data.aws_vpc.default.id

#Run a health check on the Instances. Send HTTP request to instances, looks for a HTTP 200 response.
#If an instance is marked as unhealthy, traffic will stop going to it so disruption is minimised.

	health_check {
		path			= "/"
		protocol		= "HTTP"
		matcher			= "200"
		interval		= 15
		timeout			= 3
		healthy_threshold	= 2
		unhealthy_threshold	= 2
	}
}

resource "aws_lb_listener_rule" "asg" {
	listener_arn	= aws_lb_listener.http.arn
	priority	= 100

	condition {
		path_pattern {
			values	= ["*"]
		}
	}
	
	action {
		type			= "forward"
		target_group_arn	= aws_lb_target_group.asg.arn
	}
}

#Change the below to output the DNS name of the ALB instead of the public IP

output "alb_dns_name" {
        value           = aws_lb.First_AWS_Trial.dns_name
        description     = "The domain name of the load balancer"
}
