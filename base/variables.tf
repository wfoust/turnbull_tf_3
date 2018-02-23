variable "region" {
  description = "The AWS region."
}

variable "environment" {
  default     = "base"
  description = "The environment name."
}

variable "prefix" {
  description = "The name of our org, i.e. examplecom"
}

variable "ami" {
  type        = "map"
  description = "The AMIs to launch"
  default     = {}
}

variable "instance_type" {
  description = "The type of instance to launch."
  default     = "t2.micro"
}
