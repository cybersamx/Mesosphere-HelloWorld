### Create VPC to isolate the Mesos nodes ###

# Initialization

provider "aws" {
  region = "${var.region}"
}

# Create and configure a VPC

resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "vpc-${var.vpc_name}"
  }
}

# Create subnets in the VPC

resource "aws_subnet" "subnet_public" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.subnet_cidr}"
  availability_zone = "${element(split(",", lookup(var.zones, var.region)), 0)}"

  tags {
    Name = "subnet-public-${var.vpc_name}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = "${aws_subnet.subnet_public.id}"
  route_table_id = "${aws_route_table.main.id}"
}

# Create security group

resource "aws_security_group" "open" {
  description = "Allow all traffic - insecure security group."
  vpc_id      = "${aws_vpc.main.id}"
  name        = "sgp-open"

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "mesos_master" {
  count = "${var.master_count}"
  template = "${file("mesos_master_userdata.sh")}"

  vars = {
    "zookeeper_master_urls" = "${var.zookeeper_master_urls}"
    "zookeeper_config_ip_addresses" = "${var.zookeeper_config_ip_addresses}"
    "zookeeper_id" = "${count.index + 1}"
    "quorum" = "${var.quorum}"
    "ip_address" = "${lookup(var.master_ip_addresses, count.index + 1)}"
  }
}

data "template_file" "mesos_slave" {
  count = "${var.slave_count}"
  template = "${file("mesos_slave_userdata.sh")}"

  vars = {
    "zookeeper_master_urls" = "${var.zookeeper_master_urls}"
    "ip_address" = "${lookup(var.slave_ip_addresses, count.index + 1)}"
  }
}

# Master Mesos instances
# Seems like the first 3 IP addresses of a subnet are reserved. So we start from the 4th.

resource "aws_instance" "master" {
  count                       = "${var.master_count}"
  instance_type               = "${var.instance_type}"
  ami                         = "${lookup(var.ubuntu_images, var.region)}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.open.id}"]
  user_data                   = "${element(data.template_file.mesos_master.*.rendered, count.index)}"
  private_ip                  = "${lookup(var.master_ip_addresses, count.index + 1)}"
  subnet_id                   = "${aws_subnet.subnet_public.id}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "i-mesos-master-${count.index + 1}"
  }
}

# Master Mesos instances

resource "aws_instance" "slave" {
  count                       = "${var.slave_count}"
  instance_type               = "${var.instance_type}"
  ami                         = "${lookup(var.ubuntu_images, var.region)}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.open.id}"]
  user_data                   = "${element(data.template_file.mesos_slave.*.rendered, count.index)}"
  private_ip                  = "${lookup(var.slave_ip_addresses, count.index + 1)}"
  subnet_id                   = "${aws_subnet.subnet_public.id}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "i-mesos-slave-${count.index + 1}"
  }
}

# Outputs

