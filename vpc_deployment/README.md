# ibm-adn-adc-tier-demo

![Workspace Diagram](./assets/ibmcloud_schematices_adn_adc_tier_diagram.jpg)

This Schematics Workspace module lifecycle manages:

- IBM VPC Gen2 VPC
- IBM VPC Subnets with the created VPC
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
