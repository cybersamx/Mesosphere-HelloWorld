output "message" {
  value = "${format("
Manage the Mesos cluster and Marathon jobs respectively at:
http://%s:5050/
http://%s:8080/
",
element(var.master_ip_addresses, 0),
element(var.master_ip_addresses, 0))}"
}