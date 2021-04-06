
data "ibm_is_region" "vpc_region" {
  name = var.ibm_region
}

resource "random_uuid" "namer" {}

locals {
  # set the user_data YAML template for each license type
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
  ibm_traffic_gateway_connection_count = var.ibm_transit_gateway_id == "" ? 0 : 1
}

resource "ibm_is_vpc" "vpc" {
  name                      = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}"
  resource_group            = data.ibm_resource_group.group.id
  address_prefix_management = "manual"
}

resource "ibm_is_vpc_address_prefix" "vpc_address_prefix" {
  name = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}-ap"
  zone = "${var.ibm_region}-${var.ibm_zone}"
  vpc  = ibm_is_vpc.vpc.id
  cidr = var.ibm_vpc_cidr
}

// allow all inbound
resource "ibm_is_security_group_rule" "allow_inbound" {
  depends_on = [ibm_is_vpc.vpc]
  group      = ibm_is_vpc.vpc.default_security_group
  direction  = "inbound"
  remote     = "0.0.0.0/0"
}

// all all outbound
resource "ibm_is_security_group_rule" "allow_outbound" {
  depends_on = [ibm_is_vpc.vpc]
  group      = ibm_is_vpc.vpc.default_security_group
  direction  = "outbound"
  remote     = "0.0.0.0/0"
}

resource "ibm_is_subnet" "management" {
  name                     = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-management"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = "${var.ibm_region}-${var.ibm_zone}"
  resource_group           = data.ibm_resource_group.group.id
  depends_on               = [ibm_is_vpc_address_prefix.vpc_address_prefix]
  ipv4_cidr_block          = cidrsubnet(var.ibm_vpc_cidr, 4, 0)
}

resource "ibm_is_subnet" "internal" {
  name                     = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-internal"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = "${var.ibm_region}-${var.ibm_zone}"
  resource_group           = data.ibm_resource_group.group.id
  depends_on               = [ibm_is_vpc_address_prefix.vpc_address_prefix]
  ipv4_cidr_block          = cidrsubnet(var.ibm_vpc_cidr, 4, 1)
}

resource "ibm_is_subnet" "external" {
  name                     = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-external"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = "${var.ibm_region}-${var.ibm_zone}"
  resource_group           = data.ibm_resource_group.group.id
  depends_on               = [ibm_is_vpc_address_prefix.vpc_address_prefix]
  ipv4_cidr_block          = cidrsubnet(var.ibm_vpc_cidr, 4, 2)
}

data "ibm_is_ssh_key" "ssh_key" {
  name = var.ibm_ssh_key_name
}

resource "ibm_tg_connection" "ibm_tg_connect" {
  count        = local.ibm_traffic_gateway_connection_count
  gateway      = var.ibm_transit_gateway_id
  network_type = "vpc"
  name         = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}-connection"
  network_id   = ibm_is_vpc.vpc.resource_crn
  depends_on   = [ibm_is_security_group_rule.allow_outbound, ibm_is_subnet.management, ibm_is_subnet.internal, ibm_is_subnet.external]
}

output "vpc_id" {
  value = ibm_is_vpc.vpc.id
}

output "management_subnet_id" {
  value = ibm_is_subnet.management.id
}

output "management_subnet_cidr" {
  value = ibm_is_subnet.management.ipv4_cidr_block
}

output "internal_subnet_id" {
  value = ibm_is_subnet.internal.id
}

output "internal_subnet_cidr" {
  value = ibm_is_subnet.internal.ipv4_cidr_block
}

output "external_subnet_id" {
  value = ibm_is_subnet.external.id
}

output "external_subnet_cidr" {
  value = ibm_is_subnet.external.ipv4_cidr_block
}

output "vpc_region_zone" {
  value = "${var.ibm_region}-${var.ibm_zone}"
}

output "latitude" {
  value = lookup(local.vpc_gen2_region_location_map, var.ibm_region).latitude
}

output "longitude" {
  value = lookup(local.vpc_gen2_region_location_map, var.ibm_region).longitude
}

