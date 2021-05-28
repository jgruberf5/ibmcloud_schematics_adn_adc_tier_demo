
locals {
  consul_count      = var.consul_include ? 1 : 0
  consul_vsis_count = var.volterra_voltstack ? 0 : local.consul_count
  consul_k8s_count  = var.volterra_voltstack ? local.consul_count : 0
}

module "consul_cluster_vsis" {
  source            = "./modules/consul_vsis"
  count             = local.consul_vsis_count
  resource_group    = var.ibm_resource_group
  region            = var.ibm_region
  vpc               = ibm_is_subnet.internal.vpc
  zone              = ibm_is_subnet.internal.zone
  security_group_id = ibm_is_vpc.vpc.default_security_group
  ssh_key_id        = data.ibm_is_ssh_key.ssh_key.id
  instance_profile  = var.consul_instance_profile
  subnet_id         = ibm_is_subnet.internal.id
  organization      = var.volterra_tenant
  datacenter        = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}"
  client_token      = var.consul_client_token
}

module "volterra_cluster" {
  source               = "./modules/volterra"
  count                = var.volterra_include_ce ? 1 : 0
  resource_group       = var.ibm_resource_group
  region               = var.ibm_region
  download_region      = var.ibm_download_region
  zone                 = ibm_is_subnet.internal.zone
  vpc                  = ibm_is_subnet.internal.vpc
  security_group_id    = ibm_is_vpc.vpc.default_security_group
  ssh_key_id           = data.ibm_is_ssh_key.ssh_key.id
  inside_subnet_id     = ibm_is_subnet.internal.id
  inside_gateway       = cidrhost(ibm_is_subnet.internal.ipv4_cidr_block, 1)
  inside_networks      = var.volterra_internal_networks
  outside_subnet_id    = ibm_is_subnet.external.id
  ce_version           = var.volterra_ce_version
  cluster_size         = var.volterra_cluster_size
  tenant               = var.volterra_tenant
  site_name            = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}"
  fleet_label          = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}-fleet"
  voltstack            = var.volterra_voltstack
  admin_password       = var.volterra_admin_password
  ipsec_tunnels        = var.volterra_ipsec_tunnels
  ssl_tunnels          = var.volterra_ssl_tunnels
  api_token            = var.volterra_api_token
  consul_ca_cert       = join("", module.consul_cluster_vsis.*.datacenter_ca_certificate)
  consul_https_servers = join("", module.consul_cluster_vsis.*.https_endpoints) == "" ? [] : jsondecode(join("", module.consul_cluster_vsis.*.https_endpoints))
}

module "f5_devices" {
  source                 = "./modules/f5"
  count                  = var.f5_include_bigip ? 1 : 0
  resource_group         = var.ibm_resource_group
  region                 = var.ibm_region
  download_region        = var.ibm_download_region
  zone                   = ibm_is_subnet.internal.zone
  vpc                    = ibm_is_subnet.internal.vpc
  security_group_id      = ibm_is_vpc.vpc.default_security_group
  ssh_key_id             = data.ibm_is_ssh_key.ssh_key.id
  profile                = var.f5_bigiq_profile
  management_subnet_id   = ibm_is_subnet.management.id
  internal_subnet_id     = ibm_is_subnet.internal.id
  bigip_version          = var.f5_bigip_version
  bigiq_version          = var.f5_bigiq_version
  site_name              = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}"
  admin_password         = var.f5_bigiq_admin_password
  ha_instance            = var.f5_bigiq_ha_instance
  management_floating_ip = var.f5_bigiq_management_floating_ip
  license_basekey        = var.f5_bigiq_license_basekey
  ha_license_basekey     = var.f5_bigiq_ha_license_basekey
  phone_home_url         = var.f5_bigiq_phone_home_url
  license_type           = var.f5_bigiq_license_type
  license_pool_name      = var.f5_bigiq_license_pool_name
  license_utility_regkey = var.f5_bigiq_license_utility_regkey
  license_offerings_1    = var.f5_bigiq_license_offerings_1
  license_offerings_2    = var.f5_bigiq_license_offerings_2
  license_offerings_3    = var.f5_bigiq_license_offerings_3
  license_offerings_4    = var.f5_bigiq_license_offerings_4
  license_offerings_5    = var.f5_bigiq_license_offerings_5
  license_offerings_6    = var.f5_bigiq_license_offerings_6
  license_offerings_7    = var.f5_bigiq_license_offerings_7
  license_offerings_8    = var.f5_bigiq_license_offerings_8
  license_offerings_9    = var.f5_bigiq_license_offerings_9
  license_offerings_10   = var.f5_bigiq_license_offerings_10

}
