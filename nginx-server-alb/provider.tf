# Define AWS as our provider
provider "aws" {
  region = "${var.aws_region}"
  access_key = "Please Add IAM-User_Developer-access-Key"
  secret_key = "Please Add IAM-User_Developer-secret-Key"
}
