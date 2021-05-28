data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_is_instance_profile" "profile" {
  name = var.profile
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

resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_uuid" "namer" {}

locals {
  template_file    = lookup(local.license_map, var.license_type, local.license_map["none"])
  ha_template_file = var.ha_license_basekey == "" ? local.license_map["none"] : local.license_map["bigiq_regkey"]
  # user admin_password if supplied, else set a random password
  admin_password = var.admin_password == "" ? random_password.admin_password.result : var.admin_password
  # set user_data YAML values or else set them to null for templating
  phone_home_url         = var.phone_home_url == "" ? "null" : var.phone_home_url
  license_basekey        = var.license_basekey == "none" ? "null" : var.license_basekey
  ha_license_basekey     = var.ha_license_basekey == "none" ? "null" : var.ha_license_basekey
  license_pool_name      = var.license_pool_name == "none" ? "null" : var.license_pool_name
  license_utility_regkey = var.license_utility_regkey == "none" ? "null" : var.license_utility_regkey
  license_offerings_1    = var.license_offerings_1 == "none" ? "null" : var.license_offerings_1
  license_offerings_2    = var.license_offerings_2 == "none" ? "null" : var.license_offerings_2
  license_offerings_3    = var.license_offerings_3 == "none" ? "null" : var.license_offerings_3
  license_offerings_4    = var.license_offerings_4 == "none" ? "null" : var.license_offerings_4
  license_offerings_5    = var.license_offerings_5 == "none" ? "null" : var.license_offerings_5
  license_offerings_6    = var.license_offerings_6 == "none" ? "null" : var.license_offerings_6
  license_offerings_7    = var.license_offerings_7 == "none" ? "null" : var.license_offerings_7
  license_offerings_8    = var.license_offerings_8 == "none" ? "null" : var.license_offerings_8
  license_offerings_9    = var.license_offerings_9 == "none" ? "null" : var.license_offerings_9
  license_offerings_10   = var.license_offerings_10 == "none" ? "null" : var.license_offerings_10
  floating_ip_count      = var.management_floating_ip ? 1 : 0
  ha_count               = var.ha_instance ? 1 : 0
  ha_floating_ip_count   = var.management_floating_ip ? 1 : 0
}

data "template_file" "user_data" {
  template = local.template_file
  vars = {
    bigiq_admin_password   = local.admin_password
    license_basekey        = local.license_basekey
    license_pool_name      = local.license_pool_name
    license_utility_regkey = local.license_utility_regkey
    license_offerings_1    = local.license_offerings_1
    license_offerings_2    = local.license_offerings_2
    license_offerings_3    = local.license_offerings_3
    license_offerings_4    = local.license_offerings_4
    license_offerings_5    = local.license_offerings_5
    license_offerings_6    = local.license_offerings_6
    license_offerings_7    = local.license_offerings_7
    license_offerings_8    = local.license_offerings_8
    license_offerings_9    = local.license_offerings_9
    license_offerings_10   = local.license_offerings_10
    phone_home_url         = local.phone_home_url
    template_source        = "ibm-adn-adc-tier"
    template_version       = "1.0.0"
    zone                   = var.zone
    vpc                    = var.vpc
    app_id                 = "adc-infrastructure-deployment"
  }
}

data "template_file" "ha_user_data" {
  template = local.ha_template_file
  vars = {
    bigiq_admin_password   = local.admin_password
    license_basekey        = local.ha_license_basekey
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
    zone                   = var.zone
    vpc                    = var.vpc
    app_id                 = "adc-infrastructure-deployment"
  }
}

resource "ibm_is_instance" "bigiq" {
  name           = "${var.site_name}-bigiq-01"
  resource_group = data.ibm_resource_group.group.id
  image          = ibm_is_image.bigiq_custom_image.id
  profile        = data.ibm_is_instance_profile.profile.id
  primary_network_interface {
    name            = "management"
    subnet          = var.management_subnet_id
    security_groups = [var.security_group_id]
  }
  network_interfaces {
    name            = "internal"
    subnet          = var.internal_subnet_id
    security_groups = [var.security_group_id]
  }
  vpc        = var.vpc
  zone       = var.zone
  keys       = [var.ssh_key_id]
  user_data  = data.template_file.user_data.rendered
  timeouts {
    create = "60m"
    delete = "60m"
  }
}

resource "ibm_is_floating_ip" "management_floating_ip" {
  name           = "fbigiq-${uuid()}"
  resource_group = data.ibm_resource_group.group.id
  count          = local.floating_ip_count
  target         = ibm_is_instance.bigiq.primary_network_interface.0.id
}

resource "ibm_is_instance" "ha_bigiq" {
  name           = "${var.site_name}-bigiq-02"
  count          = local.ha_count
  resource_group = data.ibm_resource_group.group.id
  image          = ibm_is_image.bigiq_custom_image.id
  profile        = data.ibm_is_instance_profile.profile.id
  primary_network_interface {
    name            = "management"
    subnet          = var.management_subnet_id
    security_groups = [var.security_group_id]
  }
  network_interfaces {
    name            = "internal"
    subnet          = var.internal_subnet_id
    security_groups = [var.security_group_id]
  }
  vpc        = var.vpc
  zone       = var.zone
  keys       = [var.ssh_key_id]
  user_data  = data.template_file.ha_user_data.rendered
  timeouts {
    create = "60m"
    delete = "60m"
  }
}

resource "ibm_is_floating_ip" "ha_management_floating_ip" {
  name           = "fbigiq-ha-${uuid()}"
  resource_group = data.ibm_resource_group.group.id
  count          = local.floating_ip_count
  target         = ibm_is_instance.ha_bigiq.0.primary_network_interface.0.id
}