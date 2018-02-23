variable "region" {
  description = "The AWS region."
}

variable "environment" {
  description = "The name of the environment."
}

variable "key_name" {
  description = "The AWS key pair to use for resources."
}

variable "key_path" {
  description = "The location of the AWS key file to use for connections."
}

variable "ami" {
  type        = "map"
  description = "A map of AMIs"
  default     = {}
}

variable "instance_type" {
  description = "The instance type to launch."
  default     = "t2.micro"
}

variable "instance_ips" {
  description = "The IPs to use for our instances"
  default     = ["10.0.1.20", "10.0.1.21"]
}

variable "prefix" {
  description = "The name of our org, i.e. examplecom"
}

variable "token" {
  description = "The Consul server token."
}