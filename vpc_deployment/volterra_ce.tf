# lookup compute profile by name
data "ibm_is_instance_profile" "ce_instance_profile" {
  name = var.volterra_ce_profile
}

# create a random password if we need it
resource "random_password" "volterra_admin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

locals {
  volterra_template_file = file("${path.module}/volterra_ce.yaml")
  # user admin_password if supplied, else set a random password
  volterra_admin_password = var.volterra_admin_password == "" ? random_password.volterra_admin_password.result : var.volterra_admin_password
  # because someone can't spell in the /etc/vpm/certified-hardware.yaml file in the qcow2 image
  volterra_certified_hardware_map = {
    voltstack = ["kvm-volstack-combo", "kvm-multi-nic-voltstack-combo"],
    voltmesh  = ["kvm-voltmesh", "kvm-multi-nic-voltmesh"]
  }
  volterra_which_stack        = var.volterra_voltstack ? "voltstack" : "voltmesh"
  volterra_inside_nic         = "eth1"
  volterra_certified_hardware = element(local.volterra_certified_hardware_map[local.volterra_which_stack].*, 1)
  volterra_instance_count     = var.volterra_include_ce ? var.volterra_cluster_size : local.volterra_tier_count
}

data "external" "volterra_site" {
  program = ["python3", "${path.module}/volterra_data_source_site_token_creator.py"]
  query = {
    tenant = var.volterra_tenant
    token = var.volterra_api_token
    site_name = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}"
    fleet_name = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}"
  }
  count = local.volterra_tier_count
}

data "template_file" "volterra_user_data" {
  template = local.volterra_template_file
  vars = {
    admin_password     = local.volterra_admin_password
    cluster_name       = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}"
    fleet_name         = data.external.volterra_site.0.result.fleet_label
    certified_hardware = local.volterra_certified_hardware
    latitude           = lookup(local.vpc_gen2_region_location_map, var.ibm_region).latitude
    longitude          = lookup(local.vpc_gen2_region_location_map, var.ibm_region).longitude
    site_token         = data.external.volterra_site.0.result.site_token
    profile            = var.volterra_ce_profile
    inside_nic         = local.volterra_inside_nic
  }
  count = local.volterra_tier_count
}

# create compute instance
resource "ibm_is_instance" "volterra_ce_instance" {
  count          = local.volterra_instance_count
  name           = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}-vce-${count.index}"
  resource_group = data.ibm_resource_group.group.id
  image          = ibm_is_image.volterra_ce_custom_image.0.id
  profile        = data.ibm_is_instance_profile.ce_instance_profile.id
  primary_network_interface {
    name              = "external"
    subnet            = ibm_is_subnet.external.id
    security_groups   = [ibm_is_vpc.vpc.default_security_group]
    allow_ip_spoofing = true
  }
  network_interfaces {
    name              = "internal"
    subnet            = ibm_is_subnet.internal.id
    security_groups   = [ibm_is_vpc.vpc.default_security_group]
    allow_ip_spoofing = true
  }
  vpc        = ibm_is_subnet.external.vpc
  zone       = ibm_is_subnet.external.zone
  keys       = [data.ibm_is_ssh_key.ssh_key.id]
  user_data  = data.template_file.volterra_user_data.0.rendered
  depends_on = [ibm_is_security_group_rule.allow_outbound]
  timeouts {
    create = "60m"
    delete = "120m"
  }
}

resource "ibm_is_floating_ip" "external_floating_ip" {
  count          = local.volterra_instance_count
  name           = "fip-${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}-vce-${count.index}"
  resource_group = data.ibm_resource_group.group.id
  target         = element(ibm_is_instance.volterra_ce_instance.*.primary_network_interface.0.id, count.index)
}
