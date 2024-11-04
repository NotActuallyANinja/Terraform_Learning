provider "aws" {
	region = "eu-west-1"
}

resource "aws_instance" "First_AWS_Trial" {
	ami	= "ami-0be8b3ed4febc3ec0"
	instance_type = "t2.micro"

	tags = {
		Name = "terraform-example"
	}
}
