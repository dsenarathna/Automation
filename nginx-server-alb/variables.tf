variable "aws_region" {
  description = "Region for the VPC"
  default = "us-east-2"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.1.0/24"
}


variable "ami" {
  description = "Ubuntu 18.04.7 AMI"
  default = "ami-0650ec2a12946c040"
}

variable "key_path" {
  description = "SSH Public Key path"
  default = "/home/ubuntu/.ssh/id_rsa.pub"
}
