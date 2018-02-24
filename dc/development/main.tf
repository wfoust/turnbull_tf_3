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
  #source = "github.com/turnbullpress/tf_vpc.git?ref=v0.0.2"
  # The above is how I referenced it in my consul module.

  #source        = "git@github.com:turnbullpress/tf_vpc.git?ref=v0.0.2"
  # The above is how he has it referenced in the book, but it's not working for me.
  # Looks like I dont have the right permissions to the repo.

  #source = "/home/bill/PycharmProjects/terraform/turnbull-book-ch4/clone_of_vpc_module_v2/tf_vpc"
  # Needed to fix a bug in Turnbull's VPC module, so I cloned it and am working off a local copy.

  source = "/home/bill/PycharmProjects/terraform/turnbull-book-ch4/clone_of_vpc_module_v2/tf_vpc"

  environment     = "${var.environment}"
  region          = "${var.region}"
  key_name        = "${var.key_name}"
  vpc_cidr            = "${var.vpc_cidr}"
  public_subnets  = ["${var.public_subnets}"]
  private_subnets = ["${var.private_subnets}"]
}

output "public_subnet_ids" {
  value = ["${module.vpc.public_subnet_ids}"]
}

output "private_subnet_ids" {
  value = ["${module.vpc.private_subnet_ids}"]
}

output "bastion_host_dns" {
  value = "${module.vpc.bastion_host_dns}"
}

output "bastion_host_ip" {
  value = "${module.vpc.bastion_host_ip}"
}
