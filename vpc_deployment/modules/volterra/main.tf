data "ibm_resource_group" "group" {
  name = var.resource_group
}

# lookup compute profile by name
data "ibm_is_instance_profile" "instance_profile" {
  name = var.profile
}

# create a random password if we need it
resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

locals {
  template_file = file("${path.module}/volterra_ce.yaml")
  # user admin_password if supplied, else set a random password
  admin_password = var.admin_password == "" ? random_password.admin_password.result : var.admin_password
  # because someone can't spell in the /etc/vpm/certified-hardware.yaml file in the qcow2 image
  certified_hardware_map = {
    voltstack = ["kvm-volstack-combo", "kvm-multi-nic-voltstack-combo"],
    voltmesh  = ["kvm-voltmesh", "kvm-multi-nic-voltmesh"]
  }
  which_stack        = var.voltstack ? "voltstack" : "voltmesh"
  inside_nic         = "eth1"
  certified_hardware = element(local.certified_hardware_map[local.which_stack].*, 1)
  vpc_gen2_region_location_map = {
    "au-syd" = {
      "latitude"  = "-33.8688",
      "longitude" = "151.2093"
    },
    "eu-de" = {
      "latitude"  = "50.1109",
      "longitude" = "8.6821"
    },
    "eu-gb" = {
      "latitude"  = "51.5074",
      "longitude" = "0.1278"
    },
    "jp-osa" = {
      "latitude"  = "34.6937",
      "longitude" = "135.5023"
    },
    "jp-tok" = {
      "latitude"  = "35.6762",
      "longitude" = "139.6503"
    },
    "us-east" = {
      "latitude"  = "38.9072",
      "longitude" = "-77.0369"
    },
    "us-south" = {
      "latitude"  = "32.7924",
      "longitude" = "-96.8147"
    }
  }
}

data "external" "site" {
  program = ["python3", "${path.module}/volterra_data_source_site_creator.py"]
  query = {
    tenant          = var.tenant
    token           = var.api_token
    site_name       = var.site_name
    fleet_name      = var.fleet_name
    inside_networks = jsonencode(var.inside_networks)
    inside_gateway  = var.inside_gateway
    consul_servers  = jsonencode(var.consul_https_servers)
    ca_cert_encoded = base64encode(var.consul_ca_cert)
  }
}

data "template_file" "user_data" {
  template = local.template_file
  vars = {
    admin_password     = local.admin_password
    cluster_name       = var.site_name
    fleet_name         = data.external.site.result.fleet_label
    certified_hardware = local.certified_hardware
    latitude           = lookup(local.vpc_gen2_region_location_map, var.region).latitude
    longitude          = lookup(local.vpc_gen2_region_location_map, var.region).longitude
    site_token         = data.external.site.result.site_token
    profile            = var.profile
    inside_nic         = local.inside_nic
  }
}

# create compute instance
resource "ibm_is_instance" "ce_instance" {
  count          = var.cluster_size
  name           = "${var.site_name}-vce-${count.index}"
  resource_group = data.ibm_resource_group.group.id
  image          = ibm_is_image.ce_custom_image.id
  profile        = data.ibm_is_instance_profile.instance_profile.id
  primary_network_interface {
    name              = "outside"
    subnet            = var.outside_subnet_id
    security_groups   = [var.security_group_id]
    allow_ip_spoofing = true
  }
  network_interfaces {
    name              = "inside"
    subnet            = var.inside_subnet_id
    security_groups   = [var.security_group_id]
    allow_ip_spoofing = true
  }
  vpc       = var.vpc
  zone      = var.zone
  keys      = [var.ssh_key_id]
  user_data = data.template_file.user_data.rendered
  timeouts {
    create = "60m"
    delete = "120m"
  }
}

resource "ibm_is_floating_ip" "external_floating_ip" {
  count          = var.cluster_size
  name           = "fip-${var.site_name}-vce-${count.index}"
  resource_group = data.ibm_resource_group.group.id
  target         = element(ibm_is_instance.ce_instance.*.primary_network_interface.0.id, count.index)
}
