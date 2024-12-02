terraform {
    backend "s3" {
        bucket  = "aws-first-project-state"
        key     = "stage/data-stores/mysql/terraform.tfstate"
        region  = "eu-west-1"

        dynamodb_table  = "Terraform_Learning_Locks"
        encrypt         = true
    }
}

provider "aws" {
	region = "eu-west-1"
}

resource "aws_db_instance" "example" {
    identifier_prefix      = "mysql-example"
    engine                 = "mysql"
    allocated_storage      = 10
    instance_class         = "db.t2.micro"
    skip_final_snapshot    = true
    db_name                = "first-db"

    username               = var.db_username
    password               = var.db_password
}