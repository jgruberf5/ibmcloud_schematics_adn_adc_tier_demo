output "instance_name" {
  value = ibm_is_instance.bigiq.name
}

output "instance_id" {
  value = ibm_is_instance.bigiq.id
}

output "management_ip" {
  value = ibm_is_instance.bigiq.primary_network_interface.0.primary_ipv4_address
}

output "management_floating_ip" {
  value = local.floating_ip_count == 1 ? ibm_is_floating_ip.management_floating_ip.0.address : ""
}

output "ha_name" {
  value = join("", ibm_is_instance.ha_bigiq.*.name)
}

output "ha_instance_id" {
  value = join("", ibm_is_instance.ha_bigiq.*.id)
}
output "ha_management_ip" {
  value = join("", ibm_is_instance.ha_bigiq.*.primary_network_interface.0.primary_ipv4_address)
}

output "ha_management_floating_ip" {
  value = local.floating_ip_count == 1 ? ibm_is_floating_ip.ha_management_floating_ip.0.address : ""
}

output "phone_home_url" {
  value = var.phone_home_url
}
