provider "aws" {
	region = "eu-west-1"
}

resource "aws_instance" "First_AWS_Trial" {
	ami	= "ami-0be8b3ed4febc3ec0"
	instance_type = "t2.micro"
	vpc_security_group_ids = [aws_security_group.instance.id]	

	user_data = <<-EOF
		#!/bin/bash
		echo "Hello, World" > index.html
		nohup busybox httpd -f -p ${var.server_port} &
		EOF

	user_data_replace_on_change = true

	tags = {
		Name = "terraform-example"
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

variable "server_port" {
	description	= "The port the server will use for http requests"
	type		= number
	default		= 8080
}

output "public_ip" {
	value		= aws_instance.First_AWS_Trial.public_ip
	description	= "The public IP address of the web server"
}
