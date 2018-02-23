provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    region = "us-east-1"
    bucket = "wfoust-remote-state-base"
    key    = "terraform.tfstate"
  }
}

module "remote_state" {
  source      = "/home/bill/PycharmProjects/terraform/turnbull-book-ch4/remote_state"
  prefix      = "${var.prefix}"
  environment = "${var.environment}"
}

data "terraform_remote_state" "web" {
  backend = "s3"

  config {
    region = "${var.region}"
    bucket = "wfoust-remote-state-web"
    key    = "terraform.tfstate"
  }
}

resource "aws_instance" "base" {
  ami           = "${lookup(var.ami, var.region)}"
  instance_type = "${var.instance_type}"
  subnet_id     = "${data.terraform_remote_state.web.public_subnet_id}"
}

resource "aws_eip" "base" {
  instance = "${aws_instance.base.id}"
  vpc      = true
}
