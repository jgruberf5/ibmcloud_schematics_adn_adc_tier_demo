# get the public image COS SQL url and default name
data "external" "bigiq_public_image" {
  program = ["python3", "${path.module}/bigiq_image_selector.py"]
  query = {
    download_region = var.download_region
    version_prefix  = var.bigiq_version
    type            = "standard"
  }
}

resource "ibm_is_image" "bigiq_custom_image" {
  name             = "${data.external.bigiq_public_image.result.image_name}-adn"
  resource_group   = data.ibm_resource_group.group.id
  href             = data.external.bigiq_public_image.result.image_sql_url
  operating_system = "centos-7-amd64"
  timeouts {
    create = "60m"
    delete = "60m"
  }
}

output "bigiq_image_name" {
  value = ibm_is_image.bigiq_custom_image.name
}

output "bigiq_image_id" {
  value = ibm_is_image.bigiq_custom_image.id
}
