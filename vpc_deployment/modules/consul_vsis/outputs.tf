output "datacenter" {
  value = var.datacenter
}

output "datacenter_ca_certificate" {
  value = tls_self_signed_cert.ca_cert.cert_pem
}

output "client_token" {
  value = local.client_token
}

output "https_endpoints" {
  value = jsonencode([
    "${ibm_is_instance.consul_server_01_instance.primary_network_interface.0.primary_ipv4_address}:8501",
    "${ibm_is_instance.consul_server_02_instance.primary_network_interface.0.primary_ipv4_address}:8501",
    "${ibm_is_instance.consul_server_03_instance.primary_network_interface.0.primary_ipv4_address}:8501"
  ])
}

output "dns_endpoints" {
  value = jsonencode([
    "${ibm_is_instance.consul_server_01_instance.primary_network_interface.0.primary_ipv4_address}:8600",
    "${ibm_is_instance.consul_server_02_instance.primary_network_interface.0.primary_ipv4_address}:8600",
    "${ibm_is_instance.consul_server_03_instance.primary_network_interface.0.primary_ipv4_address}:8600"
  ])
}

output "ca_p12" {
  value = data.external.publish_pkcs12.result.ca_p12_b64
}

output "encrypt" {
  value = base64encode(random_string.consul_cluster_key.result)
}
