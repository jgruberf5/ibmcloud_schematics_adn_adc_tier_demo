
resource "null_resource" "site_registration_decommission" {

  triggers = {
    site                = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}",
    tenant              = var.volterra_tenant
    token               = var.volterra_api_token
    size                = var.volterra_cluster_size,
    allow_ssl_tunnels   = var.volterra_ssl_tunnels ? "true" : "false"
    allow_ipsec_tunnels = var.volterra_ipsec_tunnels ? "true" : "false"
  }

  depends_on = [ibm_is_instance.volterra_ce_instance]

  provisioner "local-exec" {
    when       = create
    command    = "${path.module}/volterra_site_registration_actions.py --delay 60 --action 'registernodes' --site '${self.triggers.site}' --tenant '${self.triggers.tenant}' --token '${self.triggers.token}' --ssl ${self.triggers.allow_ssl_tunnels} --ipsec ${self.triggers.allow_ipsec_tunnels} --size ${self.triggers.size}"
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "${path.module}/volterra_site_registration_actions.py --action sitedelete --site '${self.triggers.site}' --tenant '${self.triggers.tenant}' --token '${self.triggers.token}'"
    on_failure = continue
  }
}

resource "local_file" "complete_flag" {
  filename   = "${path.module}/complete.flag"
  content    = random_uuid.namer.result
  depends_on = [null_resource.site_registration_decommission]
}

resource "null_resource" "site_token_fleet_delete" {

  triggers = {
    tenant     = var.volterra_tenant
    token      = var.volterra_api_token
    site_name  = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}"
    fleet_name = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}"
  }

  depends_on = [ibm_is_instance.volterra_ce_instance]

  provisioner "local-exec" {
    when       = destroy
    command    = "${path.module}/volterra_resource_site_token_destroy.py --site '${self.triggers.site_name}' --fleet '${self.triggers.fleet_name}' --tenant '${self.triggers.tenant}' --token '${self.triggers.token}'"
    on_failure = continue
  }
}
