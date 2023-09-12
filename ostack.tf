resource "openstack_blockstorage_volume_v3" "volume" {
  count = var.instance_num
  name  = format("%s-%s-%02d", var.instance_name, "vol", count.index + 1)
  size  = var.volume_size
}

resource "openstack_compute_volume_attach_v2" "va" {
  count       = var.instance_num
  instance_id = openstack_compute_instance_v2.my_instance[count.index].id
  volume_id   = openstack_blockstorage_volume_v3.volume[count.index].id
}

resource "openstack_networking_secgroup_v2" "fio" {
  name        = "fio"
  description = "Fio server"
}

resource "openstack_networking_secgroup_v2" "ssh" {
  name        = "ssh"
  description = "Ssh access"
}

resource "openstack_networking_secgroup_rule_v2" "fio" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8765
  port_range_max    = 8765
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.fio.id
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ssh.id
}
resource "openstack_compute_instance_v2" "my_instance" {
  count           = var.instance_num
  name            = format("%s-%02d", var.instance_name, count.index + 1)
  flavor_id       = var.flavor_id
  security_groups = concat(var.security_groups, [
    openstack_networking_secgroup_v2.fio.name,
    openstack_networking_secgroup_v2.ssh.name
  ])

  user_data = templatefile("templates/bootstrap.yaml.tpl", {
    root_pass         = var.root_pass,
    custom_repos      = var.custom_repos,
    custom_repos_type = var.custom_repos_type
  })
  network {
    uuid = var.network_id
  }
  image_id = var.image_id
}
