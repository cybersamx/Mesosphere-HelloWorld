// Available regions and zones: https://console.cloud.google.com/compute/zones

variable "instance_type" {
  description = "EC2 instance type."
}

variable "region" {
  description = "EC2 region."
  default = "us-west-2"
}

variable "key_name" {
  description = "Name of the SSH key pair for EC2 instance."
}

variable "security_group" {
  description = "Security group for this EC2 instance."
}

variable "root_device_type" {
  description = "The root AMI device type ie. ebs or instance-store."
}

# Metadata and look-up
# Note: Hash variable must be flat, hence the value is a string not an array.

variable "zones" {
  type = "map"

  default = {
    us-east-1 = "us-east-1a,us-east-1b,us-east-1c,us-east-1d,us-east-1e"
    us-west-1 = "us-west-1b,us-west-1c"
    us-west-2 = "us-west-2a,us-west-2b,us-west-2c"
  }
}

# Ubuntu 14.04

# Use this command to find the right image:
#
# aws ec2 describe-images \
# --region="us-west-2" \
# --owners "099720109477" \
# --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*" "Name=root-device-type,Values=ebs" \
# --query "sort_by(Images, &CreationDate)[*].{ID: ImageId, Name: Name, CreationDate: CreationDate}" --output table

variable "ubuntu_images" {
  type = "map"

  default = {
    us-east-1 = "ami-e5bf05f"
    us-west-1 = "ami-6f1a400f"
    us-west-2 = "ami-1d14807d"
  }
}