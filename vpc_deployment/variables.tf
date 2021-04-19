##################################################################################
# ibm_resource_group - The IBM Cloud resource group to create the VPC
##################################################################################
variable "ibm_resource_group" {
  type        = string
  default     = "default"
  description = "The IBM Cloud resource group to create the VPC"
}

##################################################################################
# ibm_region - The IBM Cloud VPC Gen 2 region to create VPC environment
##################################################################################
variable "ibm_region" {
  default     = "us-south"
  description = "The IBM Cloud VPC Gen 2 region to create VPC environment"
}

##################################################################################
# ibm_zone - The zone within the IBM Cloud region to create the VPC environment
##################################################################################
variable "ibm_zone" {
  default     = "1"
  description = "The zone within the IBM Cloud region to create the VPC environment"
}

##################################################################################
# ibm_vpc_name - The name for the IBM Gen2 VPC
##################################################################################
variable "ibm_vpc_name" {
  default = ""
  description = "The name for the IBM Gen2 VPC"
}

##################################################################################
# ibm_vpc_index - The index ID for this IBM Gen2 VPC
##################################################################################
variable "ibm_vpc_index" {
  default = "1"
  description = "The index ID for this IBM Gen2 VPC"
}

##################################################################################
# ibm_vpc_cidr - The IPv4 VPC cidr to use as the network prefix of the IBM Gen2 VPC
##################################################################################
variable "ibm_vpc_cidr" {
  default = ""
  description = "The IPv4 VPC cidr to use as the network prefix of the IBM Gen2 VPC"
}

##################################################################################
# ibm_transit_gateway_id - The IBM transit gateway ID to connect the VPC
##################################################################################
variable "ibm_transit_gateway_id" {
  default = ""
  description = "The IBM transit gateway ID to connect the VPC"
}

##################################################################################
# ibm_ssh_key_name - The name of the existing SSH key to inject into infrastructure
##################################################################################
variable "ibm_ssh_key_name" {
  default = ""
  description = "The name of the existing SSH key to inject into infrastructure"
}

##################################################################################
# ibm_download_region - The VPC region to Download the Public COS Images
##################################################################################
variable "ibm_download_region" {
  type        = string
  default     = "us-south"
  description = "The VPC region to Download the Public COS Images"
}

##################################################################################
# volterra_include_ce - Build VPC infrastructure for Volterra CE connectivity
##################################################################################
variable "volterra_include_ce" {
  type        = bool
  default     = true
  description = "Build VPC infrastructure for Volterra CE connectivity"
}

##################################################################################
# volterra_ce_version - The version of Volterra CE image to Import
##################################################################################
variable "volterra_ce_version" {
  type        = string
  default     = "7.2009.5"
  description = "The version of Volterra CE image to Import"
}

##################################################################################
# volterra_ce_profile - The name of the VPC profile to use for the Volterra CE instances
##################################################################################
variable "volterra_ce_profile" {
  type        = string
  default     = "cx2-4x8"
  description = "The name of the VPC profile to use for the Volterra CE instances"
}

##################################################################################
# volterra_tenant - The Volterra tenant (group) name
##################################################################################
variable "volterra_tenant" {
  type        = string
  default     = ""
  description = "The Volterra tenant (group) name"
}

##################################################################################
# volterra_api_token - The API token to use to register with Volterra
##################################################################################
variable "volterra_api_token" {
  type        = string
  default     = ""
  description = "The API token to use to register with Volterra"
}

##################################################################################
# volterra_cluster_size - The Volterra cluster size
##################################################################################
variable "volterra_cluster_size" {
  type        = number
  default     = 3
  description = "The Volterra cluster size"
}

##################################################################################
# volterra_voltstack - Include voltstack
##################################################################################
variable "volterra_voltstack" {
  type        = bool
  default     = false
  description = "Include voltstack"
}

##################################################################################
# volterra_admin_password - The password for the built-in admin Volterra user
##################################################################################
variable "volterra_admin_password" {
  type        = string
  default     = ""
  description = "The password for the built-in admin Volterra user"
}

##################################################################################
# volterra_ssl_tunnels - Use SSL tunnels to connect to Volterra
##################################################################################
variable "volterra_ssl_tunnels" {
  type        = bool
  default     = false
  description = "Use SSL tunnels to connect to Volterra"
}

##################################################################################
# volterra_ipsec_tunnels - Use IPSEC tunnels to connect to Volterra
##################################################################################
variable "volterra_ipsec_tunnels" {
  type        = bool
  default     = true
  description = "Use IPSEC tunnels to connect to Volterra"
}

##################################################################################
# volterra_internal_networks - Internal reachable networks
##################################################################################
variable "volterra_internal_networks" {
  type = list(object({
    cidr = string
    gw = string
  }))
  default = [ ]
  description = "Internal reachable networks"
}

##################################################################################
# consul_instance_profile - The name of the VPC profile to use for the Consul instances
##################################################################################
variable "consul_instance_profile" {
  type        = string
  default     = "cx2-4x8"
  description = "The name of the VPC profile to use for the Consul instances"
}

##################################################################################
# consul_client_token - UUID token used to register nodes and services 
##################################################################################
variable "consul_client_token" {
  type        = string
  default     = ""
  description = "UUID token used to register nodes and services"
}

##################################################################################
# f5_include_bigip - Build VPC infrastructure for F5 BIG-IP ADC tier
##################################################################################
variable "f5_include_bigip" {
  type        = bool
  default     = true
  description = "Build VPC infrastructure for F5 BIG-IP ADC tier"
}

##################################################################################
# f5_bigip_version - The version of BIG-IP image to Import
##################################################################################
variable "f5_bigip_version" {
  type        = string
  default     = "15.1"
  description = "The version of BIG-IP image to Import"
}

##################################################################################
# f5_bigiq_version - The version of BIG-IQ image to Import
##################################################################################
variable "f5_bigiq_version" {
  type        = string
  default     = "7.1"
  description = "The version of BIG-IQ image to Import"
}

##################################################################################
# f5_bigiq_profile - The name of the VPC profile to use for the F5 BIG-IQ instance
##################################################################################
variable "f5_bigiq_profile" {
  type        = string
  default     = "bx2-4x16"
  description = "The resource profile to be used when provisioning the F5 BIG-IQ instance"
}

##################################################################################
# f5_bigiq_ha_instance - Create a secondary F5 BIG-IQ sutiable for HA
##################################################################################
variable "f5_bigiq_ha_instance" {
  type        = bool
  default     = false
  description = "Create a secondary F5 BIG-IQ sutiable for HA"
}

##################################################################################
# f5_bigiq_admin_password - The password for the built-in admin F5 BIG-IQ user
##################################################################################
variable "f5_bigiq_admin_password" {
  type        = string
  default     = ""
  description = "admin account password for the F5 BIG-IQ instance"
}

##################################################################################
# f5_bigiq_management_floating_ip - Create a Floating IP for the management interface for BIG-IQ
##################################################################################
variable "f5_bigiq_management_floating_ip" {
  type        = bool
  default     = false
  description = "Create a Floating IP for the management interface for BIG-IQ"
}

##################################################################################
# f5_bigiq_license_basekey - The F5 BIQ-IP license basekey to activate against activate.f5.com
##################################################################################
variable "f5_bigiq_license_basekey" {
  type        = string
  default     = "none"
  description = "The F5 BIQ-IP license basekey to activate against activate.f5.com"
}

##################################################################################
# f5_bigiq_ha_license_basekey - The F5 BIQ-IP license basekey for the HA BIG-IQ
##################################################################################
variable "f5_bigiq_ha_license_basekey" {
  type        = string
  default     = "none"
  description = "The F5 BIQ-IP license basekey for the HA BIG-IQ"
}

##################################################################################
# f5_bigiq_phone_home_url - The web hook URL to POST status to when F5 BIG-IQ onboarding completes
##################################################################################
variable "f5_bigiq_phone_home_url" {
  type        = string
  default     = ""
  description = "The URL to POST status when BIG-IQ is finished onboarding"
}

##################################################################################
# variables to deploy various BIG-IP license pool types
##################################################################################
variable "f5_bigiq_license_type" {
  type        = string
  default     = "none"
  description = "How to license, may be 'none','bigiq_regkey','regkeypool','utilitypool'"
}

variable "f5_bigiq_license_pool_name" {
  type        = string
  default     = "none"
  description = "The name of the BIG-IP license pool to create"
}

variable "f5_bigiq_license_utility_regkey" {
  type        = string
  default     = "none"
  description = "The BIG-IP utility pool regkey to create offerings to grant"
}

variable "f5_bigiq_license_offerings_1" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "f5_bigiq_license_offerings_2" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "f5_bigiq_license_offerings_3" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "f5_bigiq_license_offerings_4" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "f5_bigiq_license_offerings_5" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "f5_bigiq_license_offerings_6" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "f5_bigiq_license_offerings_7" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "f5_bigiq_license_offerings_8" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "f5_bigiq_license_offerings_9" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "f5_bigiq_license_offerings_10" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}
