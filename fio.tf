resource "null_resource" "run_fio_server" {
  triggers = {
    a = timestamp()
  }
  count = var.instance_num
  connection {
    type     = "ssh"
    user     = "ansible"
    password = var.root_pass
    host     = openstack_compute_instance_v2.my_instance[count.index].access_ip_v4
  }
  provisioner "file" {
    source      = "templates/fio-server.service.tpl"
    destination = "/tmp/fio-server.service"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for user data script to finish'",
      "cloud-init status --wait > /dev/null",
      "sudo mv /tmp/fio-server.service /etc/systemd/system/fio-server.service",
      "sudo chown root:root /etc/systemd/system/fio-server.service",
      "sudo restorecon  /etc/systemd/system/fio-server.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start fio-server.service",
    ]
  }
}

resource "null_resource" "prepare_results_dir" {
  triggers = {
    a = timestamp()
  }

  provisioner "local-exec" {
    command = "mkdir -p ${var.results_dir}/${var.test_type}"
  }
}

resource "null_resource" "run_fio_client" {
  depends_on = [null_resource.run_fio_server]
  triggers = {
    a = timestamp()
  }
  count = var.instance_num

  provisioner "local-exec" {
    command = format("fio --output %s/%s/%s --output-format %s --client=%s fio/%s",
      var.results_dir,
      var.test_type,
      count.index,
      var.fio_output_format,
      openstack_compute_instance_v2.my_instance[count.index].access_ip_v4,
      var.test_type
    )
  }

}
