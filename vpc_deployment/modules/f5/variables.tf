##################################################################################
# resource_group - The IBM Cloud resource group to create the VPC
##################################################################################
variable "resource_group" {
  type        = string
  default     = "default"
  description = "The IBM Cloud resource group to create the VPC"
}

##################################################################################
# region - The IBM Cloud VPC Gen 2 region to create VPC environment
##################################################################################
variable "region" {
  default     = "us-south"
  description = "The IBM Cloud VPC Gen 2 region to create VPC environment"
}

##################################################################################
# zone - The zone within the IBM Cloud region to create the VPC environment
##################################################################################
variable "zone" {
  default     = "1"
  description = "The zone within the IBM Cloud region to create the VPC environment"
}

##################################################################################
# download_region - The VPC region to Download the Public COS Images
##################################################################################
variable "download_region" {
  type        = string
  default     = "us-south"
  description = "The VPC region to Download the Public COS Images"
}

##################################################################################
# profile - The name of the VPC profile to use for the BIGIQ VE instances
##################################################################################
variable "profile" {
  type        = string
  default     = "bx2-4x16"
  description = "The name of the VPC profile to use for the BIGIQ VE instances"
}

##################################################################################
# vpc - The vpc ID within the IBM Cloud region to create the VPC environment
##################################################################################
variable "vpc" {
  default     = ""
  description = "The vpc ID within the IBM Cloud region to create the VPC environment"
}

##################################################################################
# site_name - The Site name to assign the VPC environment
##################################################################################
variable "site_name" {
  default     = ""
  description = "The Site name to assign the VPC environment"
}

##################################################################################
# ssh_key_id - The ID of the existing SSH key to inject into infrastructure
##################################################################################
variable "ssh_key_id" {
  default = ""
  description = "The ID of the existing SSH key to inject into infrastructure"
}

##################################################################################
# security_group_id - The VPC security group ID to connect the BIGIQ VEs 
##################################################################################
variable "security_group_id" {
  default = ""
  description = "The VPC security group ID to connect the BIGIQ VEs"
}

##################################################################################
# bigip_version - The version of BIG-IP image to Import
##################################################################################
variable "bigip_version" {
  type        = string
  default     = "15.1"
  description = "The version of BIG-IP image to Import"
}

##################################################################################
# bigiq_version - The version of BIG-IQ image to Import
##################################################################################
variable "bigiq_version" {
  type        = string
  default     = "7.1"
  description = "The version of BIG-IQ image to Import"
}

##################################################################################
# management_subnet_id - The VPC subnet ID to connect the BIGIQ management interface 
##################################################################################
variable "management_subnet_id" {
  default = ""
  description = "The VPC subnet ID to connect the BIGIQ management interface"
}

##################################################################################
# internal_subnet_id - The VPC subnet ID to connect the BIGIQ data interface 
##################################################################################
variable "internal_subnet_id" {
  default = ""
  description = "The VPC subnet ID to connect the BIGIQ data interface"
}

##################################################################################
# ha_instance - Create a secondary F5 BIG-IQ sutiable for HA
##################################################################################
variable "ha_instance" {
  type        = bool
  default     = false
  description = "Create a secondary F5 BIG-IQ sutiable for HA"
}

##################################################################################
# admin_password - The password for the built-in admin F5 BIG-IQ user
##################################################################################
variable "admin_password" {
  type        = string
  default     = ""
  description = "admin account password for the F5 BIG-IQ instance"
}

##################################################################################
# management_floating_ip - Create a Floating IP for the management interface for BIG-IQ
##################################################################################
variable "management_floating_ip" {
  type        = bool
  default     = false
  description = "Create a Floating IP for the management interface for BIG-IQ"
}

##################################################################################
# license_basekey - The F5 BIQ-IP license basekey to activate against activate.f5.com
##################################################################################
variable "license_basekey" {
  type        = string
  default     = "none"
  description = "The F5 BIQ-IP license basekey to activate against activate.f5.com"
}

##################################################################################
# ha_license_basekey - The F5 BIQ-IP license basekey for the HA BIG-IQ
##################################################################################
variable "ha_license_basekey" {
  type        = string
  default     = "none"
  description = "The F5 BIQ-IP license basekey for the HA BIG-IQ"
}

##################################################################################
# phone_home_url - The web hook URL to POST status to when F5 BIG-IQ onboarding completes
##################################################################################
variable "phone_home_url" {
  type        = string
  default     = ""
  description = "The URL to POST status when BIG-IQ is finished onboarding"
}

##################################################################################
# variables to deploy various BIG-IP license pool types
##################################################################################
variable "license_type" {
  type        = string
  default     = "none"
  description = "How to license, may be 'none','bigiq_regkey','regkeypool','utilitypool'"
}

variable "license_pool_name" {
  type        = string
  default     = "none"
  description = "The name of the BIG-IP license pool to create"
}

variable "license_utility_regkey" {
  type        = string
  default     = "none"
  description = "The BIG-IP utility pool regkey to create offerings to grant"
}

variable "license_offerings_1" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "license_offerings_2" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "license_offerings_3" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "license_offerings_4" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "license_offerings_5" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "license_offerings_6" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "license_offerings_7" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "license_offerings_8" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "license_offerings_9" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}

variable "license_offerings_10" {
  type        = string
  default     = "none"
  description = "The BIG-IP regkey pool offering key"
}
