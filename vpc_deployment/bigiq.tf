data "ibm_is_instance_profile" "bigiq_profile" {
  name = var.f5_bigiq_profile
}

locals {
  # set the user_data YAML template for each license type
  license_map = {
    "none"         = file("${path.module}/bigiq_user_data_no_license.yaml")
    "bigiq_regkey" = file("${path.module}/bigiq_user_data_license_only.yaml")
    "regkeypool"   = file("${path.module}/bigiq_user_data_license_regkey_pool.yaml")
    "utilitypool"  = file("${path.module}/bigiq_user_data_license_utility_pool.yaml")
  }
}

resource "random_password" "bigiq_admin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

locals {
  f5_bigiq_template_file    = lookup(local.license_map, var.f5_bigiq_license_type, local.license_map["none"])
  f5_bigiq_ha_template_file = var.f5_bigiq_ha_license_basekey == "" ? local.license_map["none"] : local.license_map["bigiq_regkey"]
  # user admin_password if supplied, else set a random password
  f5_bigiq_admin_password = var.f5_bigiq_admin_password == "" ? random_password.bigiq_admin_password.result : var.f5_bigiq_admin_password
  # set user_data YAML values or else set them to null for templating
  f5_bigiq_phone_home_url         = var.f5_bigiq_phone_home_url == "" ? "null" : var.f5_bigiq_phone_home_url
  f5_bigiq_license_basekey        = var.f5_bigiq_license_basekey == "none" ? "null" : var.f5_bigiq_license_basekey
  f5_bigiq_ha_license_basekey     = var.f5_bigiq_ha_license_basekey == "none" ? "null" : var.f5_bigiq_ha_license_basekey
  f5_bigiq_license_pool_name      = var.f5_bigiq_license_pool_name == "none" ? "null" : var.f5_bigiq_license_pool_name
  f5_bigiq_license_utility_regkey = var.f5_bigiq_license_utility_regkey == "none" ? "null" : var.f5_bigiq_license_utility_regkey
  f5_bigiq_license_offerings_1    = var.f5_bigiq_license_offerings_1 == "none" ? "null" : var.f5_bigiq_license_offerings_1
  f5_bigiq_license_offerings_2    = var.f5_bigiq_license_offerings_2 == "none" ? "null" : var.f5_bigiq_license_offerings_2
  f5_bigiq_license_offerings_3    = var.f5_bigiq_license_offerings_3 == "none" ? "null" : var.f5_bigiq_license_offerings_3
  f5_bigiq_license_offerings_4    = var.f5_bigiq_license_offerings_4 == "none" ? "null" : var.f5_bigiq_license_offerings_4
  f5_bigiq_license_offerings_5    = var.f5_bigiq_license_offerings_5 == "none" ? "null" : var.f5_bigiq_license_offerings_5
  f5_bigiq_license_offerings_6    = var.f5_bigiq_license_offerings_6 == "none" ? "null" : var.f5_bigiq_license_offerings_6
  f5_bigiq_license_offerings_7    = var.f5_bigiq_license_offerings_7 == "none" ? "null" : var.f5_bigiq_license_offerings_7
  f5_bigiq_license_offerings_8    = var.f5_bigiq_license_offerings_8 == "none" ? "null" : var.f5_bigiq_license_offerings_8
  f5_bigiq_license_offerings_9    = var.f5_bigiq_license_offerings_9 == "none" ? "null" : var.f5_bigiq_license_offerings_9
  f5_bigiq_license_offerings_10   = var.f5_bigiq_license_offerings_10 == "none" ? "null" : var.f5_bigiq_license_offerings_10
  f5_bigiq_add_floating_ip        = var.f5_bigiq_management_floating_ip ? 1 : 0
  f5_bigiq_floating_ip_count      = var.f5_include_bigip ? local.f5_bigiq_add_floating_ip : 0
  f5_bigiq_ha_count               = var.f5_bigiq_ha_instance ? local.bigip_tier_count : 0
}

data "template_file" "bigiq_user_data" {
  template = local.f5_bigiq_template_file
  vars = {
    bigiq_admin_password   = local.f5_bigiq_admin_password
    license_basekey        = local.f5_bigiq_license_basekey
    license_pool_name      = local.f5_bigiq_license_pool_name
    license_utility_regkey = local.f5_bigiq_license_utility_regkey
    license_offerings_1    = local.f5_bigiq_license_offerings_1
    license_offerings_2    = local.f5_bigiq_license_offerings_2
    license_offerings_3    = local.f5_bigiq_license_offerings_3
    license_offerings_4    = local.f5_bigiq_license_offerings_4
    license_offerings_5    = local.f5_bigiq_license_offerings_5
    license_offerings_6    = local.f5_bigiq_license_offerings_6
    license_offerings_7    = local.f5_bigiq_license_offerings_7
    license_offerings_8    = local.f5_bigiq_license_offerings_8
    license_offerings_9    = local.f5_bigiq_license_offerings_9
    license_offerings_10   = local.f5_bigiq_license_offerings_10
    phone_home_url         = local.f5_bigiq_phone_home_url
    template_source        = "ibm-adn-adc-tier"
    template_version       = "1.0.0"
    zone                   = "${var.ibm_region}-${var.ibm_zone}"
    vpc                    = ibm_is_vpc.vpc.id
    app_id                 = "adc-infrastructure-deployment"
  }
}

data "template_file" "bigiq_ha_user_data" {
  template = local.f5_bigiq_ha_template_file
  vars = {
    bigiq_admin_password   = local.f5_bigiq_admin_password
    license_basekey        = local.f5_bigiq_ha_license_basekey
    license_pool_name      = "null"
    license_utility_regkey = "null"
    license_offerings_1    = "null"
    license_offerings_2    = "null"
    license_offerings_3    = "null"
    license_offerings_4    = "null"
    license_offerings_5    = "null"
    license_offerings_6    = "null"
    license_offerings_7    = "null"
    license_offerings_8    = "null"
    license_offerings_9    = "null"
    license_offerings_10   = "null"
    phone_home_url         = "null"
    template_source        = "ibm-adn-adc-tier"
    template_version       = "1.0.0"
    zone                   = "${var.ibm_region}-${var.ibm_zone}"
    vpc                    = ibm_is_vpc.vpc.id
    app_id                 = "adc-infrastructure-deployment"
  }
}

resource "ibm_is_instance" "f5_bigiq" {
  name           = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-bigiq-01"
  count          = local.bigip_tier_count
  resource_group = data.ibm_resource_group.group.id
  image          = join("", ibm_is_image.bigiq_custom_image.*.id)
  profile        = data.ibm_is_instance_profile.bigiq_profile.id
  primary_network_interface {
    name            = "management"
    subnet          = ibm_is_subnet.management.id
    security_groups = [ibm_is_vpc.vpc.default_security_group]
  }
  network_interfaces {
    name            = "internal"
    subnet          = ibm_is_subnet.internal.id
    security_groups = [ibm_is_vpc.vpc.default_security_group]
  }
  vpc        = ibm_is_vpc.vpc.id
  zone       = "${var.ibm_region}-${var.ibm_zone}"
  keys       = [data.ibm_is_ssh_key.ssh_key.id]
  user_data  = data.template_file.bigiq_user_data.rendered
  depends_on = [ibm_is_security_group_rule.allow_outbound]
  timeouts {
    create = "60m"
    delete = "60m"
  }
}

resource "ibm_is_floating_ip" "f5_bigiq_management_floating_ip" {
  name           = "f0-${random_uuid.namer.result}"
  resource_group = data.ibm_resource_group.group.id
  count          = local.f5_bigiq_floating_ip_count
  target         = ibm_is_instance.f5_bigiq.0.primary_network_interface.0.id
}

resource "ibm_is_instance" "f5_ha_bigiq" {
  name           = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-bigiq-02"
  count          = local.f5_bigiq_ha_count
  resource_group = data.ibm_resource_group.group.id
  image          = join("", ibm_is_image.bigiq_custom_image.*.id)
  profile        = data.ibm_is_instance_profile.bigiq_profile.id
  primary_network_interface {
    name            = "management"
    subnet          = ibm_is_subnet.management.id
    security_groups = [ibm_is_vpc.vpc.default_security_group]
  }
  network_interfaces {
    name            = "internal"
    subnet          = ibm_is_subnet.internal.id
    security_groups = [ibm_is_vpc.vpc.default_security_group]
  }
  vpc        = ibm_is_vpc.vpc.id
  zone       = "${var.ibm_region}-${var.ibm_zone}"
  keys       = [data.ibm_is_ssh_key.ssh_key.id]
  user_data  = data.template_file.bigiq_ha_user_data.rendered
  depends_on = [ibm_is_security_group_rule.allow_outbound]
  timeouts {
    create = "60m"
    delete = "60m"
  }
}

resource "ibm_is_floating_ip" "f5_ha_bigiq_management_floating_ip" {
  name           = "f1-${random_uuid.namer.result}"
  resource_group = data.ibm_resource_group.group.id
  count          = local.f5_bigiq_floating_ip_count
  target         = ibm_is_instance.f5_ha_bigiq.0.primary_network_interface.0.id
}

output "f5_bigiq_name" {
  value = join("", ibm_is_instance.f5_bigiq.*.name)
}

output "f5_bigiq_instance_id" {
  value = join("", ibm_is_instance.f5_bigiq.*.id)
}

output "f5_bigiq_management_ip" {
  value = join("", ibm_is_instance.f5_bigiq.*.primary_network_interface.0.primary_ipv4_address)
}

output "f5_bigiq_management_floating_ip" {
  value = local.f5_bigiq_floating_ip_count == 1 ? ibm_is_floating_ip.f5_bigiq_management_floating_ip.0.address : ""
}

output "f5_bigiq_ha_name" {
  value = join("", ibm_is_instance.f5_ha_bigiq.*.name)
}

output "f5_bigiq_ha_instance_id" {
  value = join("", ibm_is_instance.f5_ha_bigiq.*.id)
}
output "f5_bigiq_ha_management_ip" {
  value = join("", ibm_is_instance.f5_ha_bigiq.*.primary_network_interface.0.primary_ipv4_address)
}

output "f5_bigiq_ha_management_floating_ip" {
  value = local.f5_bigiq_floating_ip_count == 1 ? ibm_is_floating_ip.f5_ha_bigiq_management_floating_ip.0.address : ""
}

output "f5_bigiq_profile_id" {
  value = data.ibm_is_instance_profile.bigiq_profile.id
}
output "f5_bigiq_phone_home_url" {
  value = var.f5_bigiq_phone_home_url
}
