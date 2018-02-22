variable "region" {
  description = "The AWS region."
}

variable "prefix" {
  description = "The name of our org, i.e. examplecom"
}

variable "environment" {
  description = "The name of the environment."
}

variable "key_name" {
  description = "The AWS key pair to use for resources."
}

variable "private_key_path" {
  description = "The location of the AWS key file to use for connections."
}

variable "vpc_cidr" {
  description = "The CIDR of the VPC."
}

variable "public_subnet" {
  description = "The public subnet to populate."
}

variable "token" {
  description = "Consul server token"
}

variable "encryption_key" {
  description = "Consul encryption key."
}
