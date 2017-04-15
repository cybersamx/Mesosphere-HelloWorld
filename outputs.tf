output "user_data" {
  value = "${element(data.template_file.mesos_master.*.rendered, 0)}"
}