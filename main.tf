### Create EC2 instances ###

provider "aws" {
  region = "${var.region}"
}

# Master Mesos instances

resource "aws_instance" "master" {
  count                       = 2
  instance_type               = "${var.instance_type}"
  ami                         = "${lookup(var.ubuntu_images, var.region)}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${var.security_group}"]
  user_data                   = "${file("mesos_master_userdata.sh")}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "i-mesos-master-${count.index}"
  }
}

# Master Mesos instances

resource "aws_instance" "slave" {
  count                       = 2
  instance_type               = "${var.instance_type}"
  ami                         = "${lookup(var.ubuntu_images, var.region)}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${var.security_group}"]
  user_data                   = "${file("mesos_slave_userdata.sh")}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "i-mesos-slave-${count.index}"
  }
}
