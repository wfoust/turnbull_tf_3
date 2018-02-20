provider "aws" {
  region     = "${var.region}"
}

module "remote_state" {
  source = "/home/bill/PycharmProjects/terraform/turnbull-book-ch4/remote_state"
  prefix = "${var.prefix}"
  environment = "${var.environment}"
}

resource "aws_instance" "base" {
  ami = "${lookup(var.ami, var.region)}"
  instance_type = "${var.instance_type}"
}

resource "aws_eip" "base" {
  instance = "${aws_instance.base.id}"
}