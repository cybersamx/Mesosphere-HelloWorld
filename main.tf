### Create VPC to isolate the Mesos nodes ###

provider "aws" {
  region = "${var.region}"
}

# Create and configure a VPC

resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name = "vpc-${var.vpc_name}"
  }
}

# Create subnets in the VPC

resource "aws_subnet" "subnet_public" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr_block, var.subnet_size_bit, 0)}"
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


# Master Mesos instances
# Seems like the first 3 IP addresses of a subnet are reserved.

resource "aws_instance" "master" {
  count                       = "${var.master_count}"
  instance_type               = "${var.instance_type}"
  ami                         = "${lookup(var.ubuntu_images, var.region)}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.open.id}"]
  user_data                   = "${file("mesos_master_userdata.sh")}"
  private_ip                  = "${cidrhost(cidrsubnet(var.vpc_cidr_block, var.subnet_size_bit, 0), count.index + 4)}"
  subnet_id                   = "${aws_subnet.subnet_public.id}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "i-mesos-master-${count.index}"
  }
}

# Master Mesos instances

resource "aws_instance" "slave" {
  count                       = "${var.master_count}"
  instance_type               = "${var.instance_type}"
  ami                         = "${lookup(var.ubuntu_images, var.region)}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.open.id}"]
  user_data                   = "${file("mesos_slave_userdata.sh")}"
  private_ip                  = "${cidrhost(cidrsubnet(var.vpc_cidr_block, var.subnet_size_bit, 0), var.master_count + count.index + 4)}"
  subnet_id                   = "${aws_subnet.subnet_public.id}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "i-mesos-slave-${count.index}"
  }
}
