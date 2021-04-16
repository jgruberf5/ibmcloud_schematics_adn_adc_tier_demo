# lookup compute profile by name
data "ibm_is_instance_profile" "consul_instance_profile" {
  name = var.consul_instance_profile
}

# lookup image name for a custom image in region if we need it
data "ibm_is_image" "ubuntu" {
  name = "ibm-ubuntu-20-04-minimal-amd64-2"
}

resource "random_string" "consul_cluster_key" {
  length  = 16
  special = false
}

resource "tls_private_key" "server_01_cert" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "server_01_cert_request" {
  key_algorithm   = tls_private_key.server_01_cert.algorithm
  private_key_pem = tls_private_key.server_01_cert.private_key_pem
  dns_names = [
    "localhost",
    "server.${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}.consul",
    "volterra-discovery.consul"
  ]
  ip_addresses = [
    "127.0.0.1"
  ]
  subject {
    common_name  = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-server-01.consul"
    organization = var.volterra_tenant
  }
}

resource "tls_locally_signed_cert" "server_01_signed" {
  cert_request_pem      = tls_cert_request.server_01_cert_request.cert_request_pem
  ca_key_algorithm      = "ECDSA"
  ca_private_key_pem    = var.consul_ca_key
  ca_cert_pem           = var.consul_ca_cert
  validity_period_hours = 87659
  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

resource "tls_private_key" "server_02_cert" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "server_02_cert_request" {
  key_algorithm   = tls_private_key.server_02_cert.algorithm
  private_key_pem = tls_private_key.server_02_cert.private_key_pem
  dns_names = [
    "localhost",
    "server.${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}.consul",
    "volterra-discovery.consul"
  ]
  ip_addresses = [
    "127.0.0.1"
  ]
  subject {
    common_name  = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-server-02.consul"
    organization = var.volterra_tenant
  }
}

resource "tls_locally_signed_cert" "server_02_signed" {
  cert_request_pem      = tls_cert_request.server_02_cert_request.cert_request_pem
  ca_key_algorithm      = "ECDSA"
  ca_private_key_pem    = var.consul_ca_key
  ca_cert_pem           = var.consul_ca_cert
  validity_period_hours = 87659
  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

resource "tls_private_key" "server_03_cert" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "server_03_cert_request" {
  key_algorithm   = tls_private_key.server_03_cert.algorithm
  private_key_pem = tls_private_key.server_03_cert.private_key_pem
  dns_names = [
    "localhost",
    "server.${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}.consul",
    "volterra-discovery.consul"
  ]
  ip_addresses = [
    "127.0.0.1"
  ]
  subject {
    common_name  = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-server-03.consul"
    organization = var.volterra_tenant
  }
}

resource "tls_locally_signed_cert" "server_03_signed" {
  cert_request_pem      = tls_cert_request.server_03_cert_request.cert_request_pem
  ca_key_algorithm      = "ECDSA"
  ca_private_key_pem    = var.consul_ca_key
  ca_cert_pem           = var.consul_ca_cert
  validity_period_hours = 87659
  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

resource "tls_private_key" "client_cert" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "client_cert_request" {
  key_algorithm   = tls_private_key.client_cert.algorithm
  private_key_pem = tls_private_key.client_cert.private_key_pem
  dns_names = [
    "localhost",
    "client.${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}.consul",
    "volterra-discovery.consul"
  ]
  ip_addresses = [
    "127.0.0.1"
  ]
  subject {
    common_name  = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-client.consul"
    organization = var.volterra_tenant
  }
}

resource "tls_locally_signed_cert" "client_signed" {
  cert_request_pem      = tls_cert_request.client_cert_request.cert_request_pem
  ca_key_algorithm      = "ECDSA"
  ca_private_key_pem    = var.consul_ca_key
  ca_cert_pem           = var.consul_ca_cert
  validity_period_hours = 87659
  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

locals {
  cluster_master_token = uuid()
  client_token         = var.consul_client_token == "" ? uuid() : var.consul_client_token
}

data "template_file" "consul_server_01" {
  template = file("${path.module}/consul_server_01.yaml")
  vars = {
    ca_cert_chain        = indent(4, var.consul_ca_cert)
    server_01_cert       = indent(4, tls_locally_signed_cert.server_01_signed.cert_pem)
    server_01_key        = indent(4, tls_private_key.server_01_cert.private_key_pem)
    client_cert          = indent(4, tls_locally_signed_cert.client_signed.cert_pem)
    client_key           = indent(4, tls_private_key.client_cert.private_key_pem)
    cluster_encrypt_key  = base64encode(random_string.consul_cluster_key.result)
    cluster_master_token = local.cluster_master_token
    client_token         = local.client_token
    datacenter           = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}"
  }
}

# create server 01
resource "ibm_is_instance" "consul_server_01_instance" {
  name           = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-consul-01"
  resource_group = data.ibm_resource_group.group.id
  image          = data.ibm_is_image.ubuntu.id
  profile        = data.ibm_is_instance_profile.consul_instance_profile.id
  primary_network_interface {
    name            = "internal"
    subnet          = ibm_is_subnet.internal.id
    security_groups = [ibm_is_vpc.vpc.default_security_group]
  }
  vpc        = ibm_is_subnet.internal.vpc
  zone       = ibm_is_subnet.internal.zone
  keys       = [data.ibm_is_ssh_key.ssh_key.id]
  user_data  = data.template_file.consul_server_01.rendered
  depends_on = [ibm_is_security_group_rule.allow_outbound]
  timeouts {
    create = "60m"
    delete = "120m"
  }
}

resource "ibm_is_floating_ip" "consul_server_01_floating_ip" {
  name           = "fip-f5-consul-server-01-${random_uuid.namer.result}"
  resource_group = data.ibm_resource_group.group.id
  target         = ibm_is_instance.consul_server_01_instance.primary_network_interface.0.id
}


data "template_file" "consul_server_02" {
  template = file("${path.module}/consul_server_02.yaml")
  vars = {
    ca_cert_chain        = indent(4, var.consul_ca_cert)
    server_02_cert       = indent(4, tls_locally_signed_cert.server_02_signed.cert_pem)
    server_02_key        = indent(4, tls_private_key.server_02_cert.private_key_pem)
    client_cert          = indent(4, tls_locally_signed_cert.client_signed.cert_pem)
    client_key           = indent(4, tls_private_key.client_cert.private_key_pem)
    cluster_encrypt_key  = base64encode(random_string.consul_cluster_key.result)
    cluster_master_token = local.cluster_master_token
    client_token         = local.client_token
    datacenter           = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}"
    server_1_ip_address  = ibm_is_instance.consul_server_01_instance.primary_network_interface.0.primary_ipv4_address
  }
}

# create server 02
resource "ibm_is_instance" "consul_server_02_instance" {
  name           = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-consul-02"
  resource_group = data.ibm_resource_group.group.id
  image          = data.ibm_is_image.ubuntu.id
  profile        = data.ibm_is_instance_profile.consul_instance_profile.id
  primary_network_interface {
    name            = "internal"
    subnet          = ibm_is_subnet.internal.id
    security_groups = [ibm_is_vpc.vpc.default_security_group]
  }
  vpc        = ibm_is_subnet.internal.vpc
  zone       = ibm_is_subnet.internal.zone
  keys       = [data.ibm_is_ssh_key.ssh_key.id]
  user_data  = data.template_file.consul_server_02.rendered
  depends_on = [ibm_is_security_group_rule.allow_outbound]
  timeouts {
    create = "60m"
    delete = "120m"
  }
}

data "template_file" "consul_server_03" {
  template = file("${path.module}/consul_server_03.yaml")
  vars = {
    ca_cert_chain        = indent(4, var.consul_ca_cert)
    server_03_cert       = indent(4, tls_locally_signed_cert.server_03_signed.cert_pem)
    server_03_key        = indent(4, tls_private_key.server_03_cert.private_key_pem)
    client_cert          = indent(4, tls_locally_signed_cert.client_signed.cert_pem)
    client_key           = indent(4, tls_private_key.client_cert.private_key_pem)
    cluster_encrypt_key  = base64encode(random_string.consul_cluster_key.result)
    cluster_master_token = local.cluster_master_token
    client_token         = local.client_token
    datacenter           = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}"
    server_1_ip_address  = ibm_is_instance.consul_server_01_instance.primary_network_interface.0.primary_ipv4_address
    server_2_ip_address  = ibm_is_instance.consul_server_02_instance.primary_network_interface.0.primary_ipv4_address
  }
}

# create server 03
resource "ibm_is_instance" "consul_server_03_instance" {
  name           = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-consul-03"
  resource_group = data.ibm_resource_group.group.id
  image          = data.ibm_is_image.ubuntu.id
  profile        = data.ibm_is_instance_profile.consul_instance_profile.id
  primary_network_interface {
    name            = "internal"
    subnet          = ibm_is_subnet.internal.id
    security_groups = [ibm_is_vpc.vpc.default_security_group]
  }
  vpc        = ibm_is_subnet.internal.vpc
  zone       = ibm_is_subnet.internal.zone
  keys       = [data.ibm_is_ssh_key.ssh_key.id]
  user_data  = data.template_file.consul_server_03.rendered
  depends_on = [ibm_is_security_group_rule.allow_outbound]
  timeouts {
    create = "60m"
    delete = "120m"
  }
}

output "consul_datacenter" {
  value = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}"
}

output "consul_client_token" {
  value = "${local.client_token}"
}

output "consul_https_endpoints" {
  value = [
    "${ibm_is_instance.consul_server_01_instance.primary_network_interface.0.primary_ipv4_address}:8501",
    "${ibm_is_instance.consul_server_02_instance.primary_network_interface.0.primary_ipv4_address}:8501",
    "${ibm_is_instance.consul_server_03_instance.primary_network_interface.0.primary_ipv4_address}:8501"
  ]
}

output "consul_dns_endpoints" {
  value = [
    "${ibm_is_instance.consul_server_01_instance.primary_network_interface.0.primary_ipv4_address}:8600",
    "${ibm_is_instance.consul_server_02_instance.primary_network_interface.0.primary_ipv4_address}:8600",
    "${ibm_is_instance.consul_server_03_instance.primary_network_interface.0.primary_ipv4_address}:8600"
  ]
}
