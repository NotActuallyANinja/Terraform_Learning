provider "aws" {
	region = "eu-west-1"
}

resource "aws_s3_bucket" "terraform_state" {
	bucket = "AWS_First_Project_State"

lifecycle {
	prevent_destroy = true
	}
}


#Enable versioning so you can see the full history of the state files
resource "aws_s3_bucket_versioning" "enabled" {
	bucket = aws_s3_bucket.terraform_state.id
	versioning_configuration {
		status = "Enabled"
	}
}

#Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
	bucket = aws_s3_bucket.terraform_state.id

	rule {
		apply_server_side_encryption_by_default {
		sse_algorithm = "AES256"
		}
	}
}

#Explicitly block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket					= aws_s3_bucket.terraform_state.id
  block_public_acls 		= true
  block_public_policy		= true
  ignore_public_acls		= true
  restrict_public_buckets	= true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name			= "Terraform_Learning_Locks"
  billing_mode	= "PAY_PER_REQUEST"
  hash_key		= "LockID"
  attribute {
	name = "LockID"
	type = "S"
  }
}

output "s3_bucket_arn" {
	value		= aws_s3_bucket.terraform_state.arn
	description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
	value		= aws_dynamodb_table.terraform_locks.name
	description = "The name of the DynamoDB table"
}