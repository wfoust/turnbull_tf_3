provider "aws" {
  region = "${var.region}"
}

# The following module is what creates the S3 bucket.  Then I'll need to add
# a terraform.backend block to actually move my state to S3.
module "remote_state" {
  source      = "/home/bill/PycharmProjects/terraform/turnbull-book-ch4/remote_state"
  prefix      = "${var.prefix}"
  environment = "${var.environment}"
}

module "vpc" {
  source        = "github.com/turnbullpress/tf_vpc.git?ref=v0.0.2"
#  source        = "git@github.com:turnbullpress/tf_vpc.git?ref=v0.0.2"
  # The above is how he has it referenced in the book, but the first line is how
  # I did it in my Consul module, so I'll try that first.
  name          = "development"
  environment = "${var.environment}"
  region = "${var.region}"
  key_name = "${var.key_name}"
  cidr          = "${var.vpc_cidr}"
  public_subnets = ["${var.public_subnets}"]
  private_subnets = ["${var.private_subnets}"]
}

