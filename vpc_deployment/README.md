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



