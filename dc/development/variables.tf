variable "region" {
  description = "The AWS region."
}

variable "prefix" {
  description = "The name of our org, e.g., examplecom."
}

variable "environment" {
  description = "The name of our environment, e.g., development."
}

variable "key_name" {
  description = "The AWS key pair to use for resources."
}

variable "vpc_cidr" {
  description = "The CIDR of the VPC."
}

variable "public_subnets" {
  default     = []
  description = "The list of public subnets to populate."
}

variable "private_subnets" {
  default     = []
  description = "The list of private subnets to populate."
}
