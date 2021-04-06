terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
    }
  }
}

provider "ibm" {
  region           = var.ibm_region
  ibmcloud_timeout = 300
}

data "ibm_resource_group" "group" {
  name = var.ibm_resource_group
}
