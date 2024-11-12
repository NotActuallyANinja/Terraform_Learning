provider "aws" {
	region = "eu-west-1"
}

resource "aws_launch_configuration" "First_AWS_Trial" {
	ami	= "ami-0be8b3ed4febc3ec0"
	instance_type = "t2.micro"
	vpc_security_group_ids = [aws_security_group.instance.id]	

	user_data = <<-EOF
		#!/bin/bash
		echo "Hello, World" > index.html
		nohup busybox httpd -f -p ${var.server_port} &
		EOF

	#Required when using a launch configuration with an autoscaling group
	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_security_group" "instance" {
	name = "terraform-example-instance"
	
	ingress {
		from_port	= var.server_port
		to_port		= var.server_port
		protocol	= "tcp"
		cidr_blocks	= ["0.0.0.0/0"]
	}
}

resource "aws_autoscaling_group" "First_AWS_Trial" {
	launch configuration	= aws_launch_configuration.First_AWS_Trial.name
	vpc_zone_identifier	= data.aws_subnets.default.ids

	min_size = 2
	max_size = 10

	tag {
		key			= "Name"
		value			= "terraform-asg-example"
		propagate_at_launch	= true
	}
}

variable "server_port" {
	description	= "The port the server will use for http requests"
	type		= number
	default		= 8080
}

output "public_ip" {
	value		= aws_instance.First_AWS_Trial.public_ip
	description	= "The public IP address of the web server"
}
