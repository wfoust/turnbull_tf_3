provider "aws" {
  region = "${var.region}"
}

provider "consul" {
  address = "${data.terraform_remote_state.consul.consul_server_address.0}:8500"
  datacenter = "consul"
}

terraform {
  backend "s3" {
    bucket = "wfoust-remote-state-web"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}

module "remote_state" {
  source = "/home/bill/PycharmProjects/terraform/turnbull-book-ch4/remote_state"
  prefix = "${var.prefix}"
  environment = "${var.environment}"
}

module "vpc" {
  source        = "github.com/wfoust/tf_vpc_2.git?ref=v0.0.1"
  name          = "web"
  cidr          = "10.0.0.0/16"
  public_subnet = "10.0.1.0/24"
  # private_subnets = ["10.0.100.0/24"]  This is listed in his VPC module, but not mine
}

data "template_file" "index" {
  count    = "${length(var.instance_ips)}"
  template = "${file("files/index.html.tpl")}"

  vars {
    hostname = "web-${format("%03d", count.index + 1)}"
  }
}

data "terraform_remote_state" "consul" {
  backend = "s3"
  config {
    region = "${var.region}"
    bucket = "wfoust-remote-state-consul"
    key = "terraform.tfstate"
  }
}

resource "consul_key_prefix" "web" {
  token = "${var.token}"
  path_prefix = "web/config/"
  subkeys = {
    "public_dns" = "${aws_elb.web.dns_name}"
  }
}

resource "aws_instance" "web" {
  ami                         = "${lookup(var.ami, var.region)}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${module.vpc.public_subnet_id}"
  private_ip                  = "${var.instance_ips[count.index]}"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    "${aws_security_group.web_host_sg.id}",
  ]

  tags {
    Name = "web-${format("%03d", count.index + 1)}"
  }

  count = "${length(var.instance_ips)}"

  connection {
    user        = "ubuntu"
    private_key = "${file(var.key_path)}"
  }

  provisioner "file" {
    content     = "${element(data.template_file.index.*.rendered, count.index)}"
    destination = "/tmp/index.html"
  }

  provisioner "remote-exec" {
    script = "files/bootstrap_puppet.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/index.html /var/www/html/index.html",
    ]
  }
}

resource "aws_elb" "web" {
  name            = "web-elb"
  subnets         = ["${module.vpc.public_subnet_id}"]
  security_groups = ["${aws_security_group.web_inbound_sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances = ["${aws_instance.web.*.id}"]
}

resource "aws_security_group" "web_inbound_sg" {
  name        = "web_inbound"
  description = "Allow HTTP from Anywhere"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_host_sg" {
  name        = "web_host"
  description = "Allow SSH & HTTP to web hosts"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}