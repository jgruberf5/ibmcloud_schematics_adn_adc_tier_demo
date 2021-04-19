# ibm-adn-adc-tier-demo

![Workspace Diagram](./assets/ibmcloud_schematices_adn_adc_tier_diagram.jpg)

This Schematics Workspace module lifecycle manages:

- IBM VPC Gen2 VPC
- IBM VPC Subnets within the created VPC
- IBM Custom Images for

    - Volterra CE Generic Hardware
    - F5 BIG-IP
    - F5 BIGIQ

- Consul Cluster VSIs
- Volterra CE VSI (optional)
- Volterra Site
- Volterra Fleet
- Volterra Network Connector to the global shared/public network
- Volterra Virtual Network exporting routes to IBM Transit Gateway networks
- Votlerra Discovery for Consul VSIs
- BIGIQ VSIs (optional)

The application of this Workspace module results in the necessary Volterra system namespace resources required to connect workloads routable via IBM Transit Gateways to the Volterra ADN. The output includes the CA certificate and the Consul client access token to register services with the Consul cluster which in-turn becomes available by service name to the Volterra ADN.
### Variables values
You will have to define the following variables:

| Key | Definition | Required/Optional | Default Value |
| --- | ---------- | ----------------- | ------------- |
| `ibm_resource_group` | The resource group to create the VPC and VSIs | optional | default |
| `ibm_region` | The IBM Cloud region to create the VPC | optional | us-south |
| `ibm_zone` | The zone number within the region to create the VPC | optional | 1 |
| `ibm_vpc_name` | VPC name, will also be the Volterra site name prefix | required |  |
| `ibm_vpc_index` | Index number allowing for mulitple VPC in the same zone  | required | 1 |
| `ibm_vpc_cidr` | The VPC prefix CIDR | required | |
| `ibm_transit_gateway_id` | The optional IBM transit gateway to connect the VPC | optional | |
| `ibm_ssh_key_name` | The name of the IBM stored SSH key to inject into VSIs | required |  |
| `ibm_download_region` | The IBM COS region to download the custom images | optional | us-south |
| `volterra_include_ce` | Create Volterra CE VSIs and Volterra ADN objects | optional | true |
| `volterra_ce_version` | The Volterra version to download from the F5 COS catalog | optional | 7.2009.5 |
| `volterra_ce_profile` | The VSI profile to use for Volterra CE instances | optional | cx2-4x8 |
| `volterra_tenant` | The Volterra tenant (group) name | required | |
| `volterra_api_token` | The Volterra API token used to manage Volterra resources | required | |
| `volterra_cluster_size` | The number of Volterra CE instances in the site cluster | optional | 3 |
| `volterra_voltstack` | Add the Voltstack components to the Voltmesh in the CE instances | optional | false |
| `volterra_admin_password` | The admin user password for the CE instances | optional | randomized string |
| `volterra_ssl_tunnels` | Allow SSL tunnels to connect the Volterra CE to the RE | optional | false |
| `volterra_ipsec_tunnels` | Allow IPSEC tunnels to connect the Volterra CE to the RE | optional | true |
| `volterra_internal_networks` | List of HCL object defining IPv4 CIDRs (cidr attribute) and IPv4 gateway (gw attribute) to connect via the CE VSIs | optional | [] |
| `consul_instance_profile` | The VSI profile to use for Consul instances | optional | cx2-4x8 |
| `consul_client_token` | The UUID value to use for the Consul client ACL token | optional | auto generate |
| `f5_include_bigip` | Include BIG-IP, BIGIQ components in deploy | optional | true |
| `f5_bigip_version` | The BIG-IP version to downlaod from the F5 COS catalog | optional | 15.1 |
| `f5_bigiq_version` | The BIGIQ version to download from the F5 COS catalog | optional | 7.1 |
| `f5_bigiq_profile` | The VSI profile to use for BIGIQ instances | optional | bx2-4x16 |
| `f5_bigiq_ha_instance` | Create a secondary BIGIQ instance for HA | optional | false |
| `f5_bigiq_admin_password` | The password to set for the admin BIGIQ users | optional | randomized string |
| `f5_bigiq_management_floating_ip` | Create a floating IP for the BIGIQ first instance | optional | false |
| `f5_bigiq_license_basekey` | The license basekey to use for the BIGIQ first instance | optional ||
| `f5_bigiq_ha_license_basekey` | The license basekey to use for the BIGIQ HA instance | optional ||
| `f5_bigiq_license_type` | Type of license pool to crete on the BIGIQ first instance. Must be `none`, `regkeypool`, or `utilitypool`. | optional | none |
| `f5_bigiq_license_pool_name` | The BIGIQ license pool name to create | optional ||
| `f5_bigiq_utility_regkey` | The utility pool regkey to build BIGIQ licenses | optional ||
| `f5_bigiq_license_offerings_1` | The BIGIQ regkey pool licenes entry | optional ||
| `f5_bigiq_license_offerings_2` | The BIGIQ regkey pool licenes entry | optional ||
| `f5_bigiq_license_offerings_3` | The BIGIQ regkey pool licenes entry | optional ||
| `f5_bigiq_license_offerings_4` | The BIGIQ regkey pool licenes entry | optional ||
| `f5_bigiq_license_offerings_5` | The BIGIQ regkey pool licenes entry | optional ||
| `f5_bigiq_license_offerings_6` | The BIGIQ regkey pool licenes entry | optional ||
| `f5_bigiq_license_offerings_7` | The BIGIQ regkey pool licenes entry | optional ||
| `f5_bigiq_license_offerings_8` | The BIGIQ regkey pool licenes entry | optional ||
| `f5_bigiq_license_offerings_9` | The BIGIQ regkey pool licenes entry | optional ||
| `f5_bigiq_license_offerings_10` | The BIGIQ regkey pool licenes entry | optional ||