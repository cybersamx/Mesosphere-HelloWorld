output "master_public_ip_addresses" {
  value = "${join("\n", aws_instance.master.*.public_ip)}"
}

output "slave_public_ip_addresses" {
  value = "${join("\n", aws_instance.slave.*.public_ip)}"
}