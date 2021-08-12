output "datacenter" {
  value = var.datacenter
}

output "datacenter_ca_certificate" {
  value = tls_self_signed_cert.ca_cert.cert_pem
}

output "client_token" {
  value = local.client_token
}
output "ca_p12" {
  value = data.external.publish_pkcs12.result.ca_p12_b64
}

output "encrypt" {
  value = base64encode(random_string.consul_cluster_key.result)
}
