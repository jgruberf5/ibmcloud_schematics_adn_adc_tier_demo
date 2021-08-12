output "vpc_id" {
  value = ibm_is_vpc.vpc.id
  description = "ADC VPC identifier"
}

output "management_subnet_id" {
  value = ibm_is_subnet.management.id
  description = "ADC tier management subnet indentifier"
}

output "management_subnet_cidr" {
  value = ibm_is_subnet.management.ipv4_cidr_block
  description = "ADC management IPv4 CIDR"
}

output "internal_subnet_id" {
  value = ibm_is_subnet.internal.id
  description = "ADC VPC internal subnet indentifier"
}

output "internal_subnet_cidr" {
  value = ibm_is_subnet.internal.ipv4_cidr_block
  description = "ADC internal IPv4 CIDR"
}

output "external_subnet_id" {
  value = ibm_is_subnet.external.id
  description = "ADC VPC external subnet indentifier"
}

output "external_subnet_cidr" {
  value = ibm_is_subnet.external.ipv4_cidr_block
  description = "ADC external IPv4 CIDR"
}

output "vpc_region_zone" {
  value = "${var.ibm_region}-${var.ibm_zone}"
  description = "ADC tier IBM cloud region"
}

output "consul_datacenter" {
  value = join("", module.consul_cluster_vsis.*.datacenter)
  description = "ADC tier Consul datacenter"
}

output "consul_datacenter_ca_certificate" {
  value = join("", module.consul_cluster_vsis.*.datacenter_ca_certificate)
  description = "ADC tier Consul datacenter CA certificate"
}

output "consul_client_token" {
  value = join("", module.consul_cluster_vsis.*.client_token)
  description = "ADC tier Consul client ACL token with right to register nodes and service"
}

output "consul_ca_p12" {
  value = join("", module.consul_cluster_vsis.*.ca_p12)
  description = "ADC tier Consul CA PKCS12 bundle to sign external certificate requests"
}

output "consul_encrypt" {
  value = join("", module.consul_cluster_vsis.*.encrypt)
  description = "ADC tier Consul RPC encryption secret"
}

output "voltconsole_endpoint" {
  value = join("", module.volterra_cluster.*.voltconsole_endpoint)
  description = "ADC tier Volterra Volt Console endpoint"
}