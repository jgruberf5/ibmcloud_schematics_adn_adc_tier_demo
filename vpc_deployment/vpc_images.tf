locals {
  bigip_tier_count = var.f5_include_bigip ? 1 : 0
  volterra_tier_count = var.volterra_include_ce ? 1 : 0
}

# get the public image COS SQL url and default name
data "external" "bigip_public_image_all" {
  program = ["python3", "${path.module}/bigip_image_selector.py"]
  query = {
    download_region = var.ibm_download_region
    version_prefix  = var.f5_bigip_version
    type            = "all"
  }
  count = local.bigip_tier_count
}

# get the public image COS SQL url and default name
data "external" "bigip_public_image_ltm" {
  program = ["python3", "${path.module}/bigip_image_selector.py"]
  query = {
    download_region = var.ibm_download_region
    version_prefix  = var.f5_bigip_version
    type            = "ltm"
  }
  count = local.bigip_tier_count
}

# get the public image COS SQL url and default name
data "external" "bigiq_public_image" {
  program = ["python3", "${path.module}/bigiq_image_selector.py"]
  query = {
    download_region = var.ibm_download_region
    version_prefix  = var.f5_bigiq_version
    type            = "standard"
  }
  count = local.bigip_tier_count
}

# get the public image COS SQL url and default name
data "external" "volterra_public_image" {
  program = ["python3", "${path.module}/volterra_image_selector.py"]
  query = {
    download_region = var.ibm_download_region
    version_prefix  = var.volterra_ce_version
  }
  count = local.volterra_tier_count
}


resource "ibm_is_image" "bigip_custom_image_all" {
  name             = "${data.external.bigip_public_image_all.0.result.image_name}-adn"
  resource_group   = data.ibm_resource_group.group.id
  href             = data.external.bigip_public_image_all.0.result.image_sql_url
  operating_system = "centos-7-amd64"
  timeouts {
    create = "60m"
    delete = "60m"
  }
  count = local.bigip_tier_count
}

resource "ibm_is_image" "bigip_custom_image_ltm" {
  name             = "${data.external.bigip_public_image_ltm.0.result.image_name}-adn"
  resource_group   = data.ibm_resource_group.group.id
  href             = data.external.bigip_public_image_ltm.0.result.image_sql_url
  operating_system = "centos-7-amd64"
  timeouts {
    create = "60m"
    delete = "60m"
  }
  count = local.bigip_tier_count
}

resource "ibm_is_image" "bigiq_custom_image" {
  name             = "${data.external.bigiq_public_image.0.result.image_name}-adn"
  resource_group   = data.ibm_resource_group.group.id
  href             = data.external.bigiq_public_image.0.result.image_sql_url
  operating_system = "centos-7-amd64"
  timeouts {
    create = "60m"
    delete = "60m"
  }
  count = local.bigip_tier_count
}

resource "ibm_is_image" "volterra_ce_custom_image" {
  name             = "${data.external.volterra_public_image.0.result.image_name}-adn"
  resource_group   = data.ibm_resource_group.group.id
  href             = data.external.volterra_public_image.0.result.image_sql_url
  operating_system = "centos-7-amd64"
  timeouts {
    create = "60m"
    delete = "60m"
  }
  count = local.volterra_tier_count
}

output "bigip_all_image_name" {
  value = join("", ibm_is_image.bigip_custom_image_all.*.name)
}

output "bigip_all_image_id" {
  value = join("", ibm_is_image.bigip_custom_image_all.*.id)
}

output "bigip_ltm_image_name" {
  value = join("", ibm_is_image.bigip_custom_image_ltm.*.name)
}

output "bigip_ltm_image_id" {
  value = join("", ibm_is_image.bigip_custom_image_ltm.*.id)
}

output "bigiq_image_name" {
  value = join("", ibm_is_image.bigiq_custom_image.*.name)
}

output "bigiq_image_id" {
  value = join("", ibm_is_image.bigiq_custom_image.*.id)
}

output "volterra_ce_image_name" {
  value = join("", ibm_is_image.volterra_ce_custom_image.*.name)
}

output "volterra_ce_image_id" {
  value = join("", ibm_is_image.volterra_ce_custom_image.*.id)
}