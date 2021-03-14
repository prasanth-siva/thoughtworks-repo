variable "private_subnets" { type = list }
variable "private_subnet_name" { type = list }
variable "public_subnets" { type = list }
variable "public_subnet_name" { type = list }
variable "aws_region" {}
variable "region" {default = "us-east-1"}
variable "tier" {
  type = string 
  default = ""
}

variable "service" {
  type        = string
  description = "Specify the name of service."
  default     = "liferay"
}
variable "vpc_cidr_block" {}
variable "usecase" {}
variable "key_pair" {}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}
variable "instance_type" {}

variable "staging_setup" { type = map }
variable "prod_setup" { type = map }

variable "environment" {}
variable "product" {}
variable "monitoring" {}
#variable "squid_instance_type" {}
variable "zone_name" {}
variable "ec2_read_iam_role" {}
variable "ami_names" {type = map }