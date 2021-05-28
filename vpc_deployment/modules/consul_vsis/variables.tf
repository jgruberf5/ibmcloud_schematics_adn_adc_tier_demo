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
  default     = ""
  description = "The zone within the IBM Cloud region to create the VPC environment"
}

##################################################################################
# vpc - The vpc ID within the IBM Cloud region to create the VPC environment
##################################################################################
variable "vpc" {
  default     = ""
  description = "The vpc ID within the IBM Cloud region to create the VPC environment"
}

##################################################################################
# ssh_key_id - The ID of the existing SSH key to inject into infrastructure
##################################################################################
variable "ssh_key_id" {
  default = ""
  description = "The ID of the existing SSH key to inject into infrastructure"
}

##################################################################################
# subnet_id - The VPC subnet ID to connect the Consul cluster 
##################################################################################
variable "subnet_id" {
  default = ""
  description = "The VPC subnet ID to connect the Consul cluster"
}

##################################################################################
# security_group_id - The VPC security group ID to connect the Consul cluster 
##################################################################################
variable "security_group_id" {
  default = ""
  description = "The VPC security group ID to connect the Consul cluster"
}

##################################################################################
# organization - The organization for certificates
##################################################################################
variable "organization" {
  type        = string
  default     = ""
  description = "The organization for certificates"
}

##################################################################################
# datacenter - The datacenter for the Consul cluster
##################################################################################
variable "datacenter" {
  type        = string
  default     = ""
  description = "The datacenter for the Consul cluster"
}


##################################################################################
# instance_profile - The name of the VPC profile to use for the Consul instances
##################################################################################
variable "instance_profile" {
  type        = string
  default     = "cx2-4x8"
  description = "The name of the VPC profile to use for the Consul instances"
}

##################################################################################
# client_token - UUID token used to register nodes and services 
##################################################################################
variable "client_token" {
  type        = string
  default     = ""
  description = "UUID token used to register nodes and services"
}
