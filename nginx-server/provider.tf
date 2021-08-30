# Define AWS as our provider
provider "aws" {
  region = "${var.aws_region}"
  access_key = "Please add your IAM access Key"
  secret_key = "Please add your IAM secret Key"
}
