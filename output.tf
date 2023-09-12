output "instance_ips" {
  value = {
    for instance in openstack_compute_instance_v2.my_instance :
    instance.name => instance.access_ip_v4
  }
}
