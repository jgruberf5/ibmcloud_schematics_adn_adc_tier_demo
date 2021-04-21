
resource "null_resource" "site_registration_decommission" {

  triggers = {
    site                = var.site_name,
    tenant              = var.tenant
    token               = var.api_token
    size                = var.cluster_size,
    allow_ssl_tunnels   = var.ssl_tunnels ? "true" : "false"
    allow_ipsec_tunnels = var.ipsec_tunnels ? "true" : "false"
  }

  depends_on = [ibm_is_instance.ce_instance]

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
  content    = uuid()
  depends_on = [null_resource.site_registration_decommission]
}

resource "null_resource" "site_token_fleet_delete" {

  triggers = {
    tenant     = var.tenant
    token      = var.api_token
    site_name  = var.site_name
    fleet_name = var.fleet_name
  }

  depends_on = [ibm_is_instance.ce_instance]

  provisioner "local-exec" {
    when       = destroy
    command    = "${path.module}/volterra_resource_site_destroy.py --site '${self.triggers.site_name}' --fleet '${self.triggers.fleet_name}' --tenant '${self.triggers.tenant}' --token '${self.triggers.token}'"
    on_failure = continue
  }
}
