#!/usr/bin/env python3

import sys
import json
import urllib.request

from urllib.error import HTTPError


def get_tenant_id(tenant, token):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    try:
        url = "https://%s.console.ves.volterra.io/api/web/namespaces/system" % tenant
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
        return json.load(response)['system_metadata']['tenant']
    except HTTPError as her:
        sys.stderr.write(
            "Error retrieving tenant ID - %s\n" % her)
        sys.exit(1)


def assure_site_token(tenant, token, site_token_name):
    site_token_name = site_token_name.encode('utf-8').decode('utf-8')
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # Does the site token exist
    try:
        url = "https://%s.console.ves.volterra.io/api/register/namespaces/system/tokens/%s" % (
            tenant, site_token_name)
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
        return json.load(response)['system_metadata']['uid']
    except HTTPError as her:
        if her.code == 404:
            try:
                url = "https://%s.console.ves.volterra.io/api/register/namespaces/system/tokens" % tenant
                headers['volterra-apigw-tenant'] = tenant
                headers['content-type'] = 'application/json'
                data = {
                    "metadata": {
                        "annotations": {},
                        "description": "Site Authorization Token for %s" % site_token_name,
                        "disable": False,
                        "labels": {},
                        "name": site_token_name,
                        "namespace": "system"
                    },
                    "spec": {}
                }
                data = json.dumps(data)
                request = urllib.request.Request(
                    url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
                response = urllib.request.urlopen(request)
                site_token = json.load(response)
                return site_token['system_metadata']['uid']
            except HTTPError as err:
                sys.stderr.write(
                    "Error creating site token resources %s: %s\n" % (url, err))
                sys.exit(1)
        else:
            sys.stderr.write(
                "Error retrieving site token resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error retrieving site token resources %s\n" % er)
        sys.exit(1)


def assure_fleet(tenant, token, fleet_name, tenant_id, internal_networks):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    if internal_networks:
        # Does virtual network exist
        try:
            url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/virtual_networks/%s" % (
                tenant, fleet_name)
            request = urllib.request.Request(
                url, headers=headers, method='GET')
            response = urllib.request.urlopen(request)
        except HTTPError as her:
            if her.code == 404:
                try:
                    v_static_routes = []
                    for net in internal_networks:
                        v_route = {
                            "ip_prefixes": [net['cidr']],
                            "ip_address": net['gw'],
                            "attrs": ['ROUTE_ATTR_INSTALL_HOST', 'ROUTE_ATTR_INSTALL_FORWARDING']
                        }
                        v_static_routes.append(v_route)
                    url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/virtual_networks" % tenant
                    headers['volterra-apigw-tenant'] = tenant
                    headers['content-type'] = 'application/json'
                    data = {
                        "namespace": "system",
                        "metadata": {
                            "name": fleet_name,
                            "namespace": "system",
                            "labels": {
                                "ves.io/fleet": fleet_name
                            },
                            "annotations": {},
                            "description": "Routes internal to %s" % fleet_name,
                            "disable": False
                        },
                        "spec": {
                            "site_local_inside_network": {},
                            "static_routes": v_static_routes
                        }
                    }
                    data = json.dumps(data)
                    request = urllib.request.Request(
                        url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
                    response = urllib.request.urlopen(request)
                except HTTPError as her:
                    sys.stderr.write(
                        "Error creating virtual_networks resources %s: %s - %s\n" % (url, data, her))
                    sys.exit(1)
            else:
                sys.stderr.write(
                    "Error retrieving virtual_networks resources %s: %s\n" % (url, her))
                sys.exit(1)
    # Does Global Network connector exist?
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/network_connectors/%s" % (
            tenant, fleet_name)
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
    except HTTPError as her:
        if her.code == 404:
            try:
                url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/network_connectors" % tenant
                headers['volterra-apigw-tenant'] = tenant
                headers['content-type'] = 'application/json'
                data = {
                    "namespace": "system",
                    "metadata": {
                        "name": fleet_name,
                        "namespace": None,
                        "labels": {},
                        "annotations": {},
                        "description": "connecting %s to the global shared network" % fleet_name,
                        "disable": False
                    },
                    "spec": {
                        "sli_to_global_dr": {
                            "global_vn": {
                                "tenant": "ves-io",
                                "namespace": "shared",
                                "name": "public"
                            }
                        },
                        "disable_forward_proxy": {}
                    }
                }
                data = json.dumps(data)
                request = urllib.request.Request(
                    url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
                response = urllib.request.urlopen(request)
            except HTTPError as her:
                sys.stderr.write(
                    "Error creating network_connectors resources %s: %s - %s\n" % (url, data, her))
                sys.exit(1)
        else:
            sys.stderr.write(
                "Error retrieving network_connectors resources %s: %s\n" % (url, her))
            sys.exit(1)
    # Does the fleet exist
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/fleets/%s" % (
            tenant, fleet_name)
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
        return json.load(response)['spec']['fleet_label']
    except HTTPError as her:
        if her.code == 404:
            try:
                url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/fleets" % tenant
                headers['volterra-apigw-tenant'] = tenant
                headers['content-type'] = 'application/json'
                data = {
                    "namespace": "system",
                    "metadata": {
                        "name": "f5-dataai-app-1-us-south-3-1",
                        "namespace": None,
                                "labels": {},
                                "annotations": {},
                                "description": "Fleet provisioning object for %s" % fleet_name,
                                "disable": None
                    },
                    "spec": {
                        "fleet_label": fleet_name,
                        "volterra_software_version": None,
                        "network_connectors": [
                            {
                                "kind": "network_connector",
                                "uuid": None,
                                "tenant": tenant_id,
                                "namespace": "system",
                                "name": fleet_name
                            }
                        ],
                        "network_firewall": None,
                        "operating_system_version": None,
                        "outside_virtual_network": None,
                        "inside_virtual_network": [
                            {
                                "kind": "virtual_network",
                                "uid": None,
                                "tenant": tenant_id,
                                "namespace": "system",
                                "name": fleet_name
                            }
                        ],
                        "default_config": {},
                        "no_bond_devices": {},
                        "no_storage_interfaces": {},
                        "no_storage_device": {},
                        "default_storage_class": {},
                        "no_dc_cluster_group": {},
                        "disable_gpu": {},
                        "no_storage_static_routes": {},
                        "enable_default_fleet_config_download": None,
                        "logs_streaming_disabled": {},
                        "deny_all_usb": {}
                    }
                }
                data = json.dumps(data)
                request = urllib.request.Request(
                    url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
                response = urllib.request.urlopen(request)
                return json.load(response)['spec']['fleet_label']
            except HTTPError as her:
                sys.stderr.write(
                    "Error creating fleets resources %s: %s - %s\n" % (url, data, her))
                sys.exit(1)
        else:
            sys.stderr.write(
                "Error retrieving feet resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error retrieving fleet resources %s\n" % er)
        sys.exit(1)


def assure_service_discovery(tenant, token, site, tenant_id, consul_servers, ca_cert_encoded):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    for indx, consul_server in enumerate(consul_servers):
        name = "%s-consul-%d" % (site, indx)
        # Does service discovery exist
        try:
            url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/discoverys/%s" % (
                tenant, name)
            request = urllib.request.Request(
                url, headers=headers, method='GET')
            response = urllib.request.urlopen(request)
        except HTTPError as her:
            if her.code == 404:
                try:
                    url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/discoverys" % tenant
                    data = {
                        "namespace": "system",
                        "metadata": {
                            "name": name,
                            "namespace": None,
                            "labels": {},
                            "annotations": {},
                            "description": None,
                            "disable": False
                        },
                        "spec": {
                            "where": {
                                "site": {
                                    "ref": [{
                                        "kind": "site",
                                        "uid": None,
                                        "tenant": tenant_id,
                                        "namespace": "system",
                                        "name": site
                                    }],
                                    "network_type": "VIRTUAL_NETWORK_SITE_LOCAL_INSIDE"
                                }
                            },
                            "discovery_consul": {
                                "access_info": {
                                    "connection_info": {
                                        "api_server": consul_server,
                                        "tls_info": {
                                            "server_name": None,
                                            "certificate_url": None,
                                            "certificate": None,
                                            "key_url": None,
                                            "ca_certificate_url": None,
                                            "trusted_ca_url": "string:///%s" % ca_cert_encoded
                                        }
                                    },
                                    "scheme": None,
                                    "http_basic_auth_info": None
                                },
                                "publish_info": {
                                    "disable": {}
                                }
                            }
                        }
                    }
                    data = json.dumps(data)
                    request = urllib.request.Request(
                        url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
                    response = urllib.request.urlopen(request)
                except HTTPError as her:
                    sys.stderr.write(
                        "Error creating discoverys resources %s: %s - %s\n" % (url, data, her))
                    sys.exit(1)
            else:
                sys.stderr.write(
                    "Error retrieving discoverys resources %s: %s\n" % (url, her))
                sys.exit(1)


def main():
    jsondata = json.loads(sys.stdin.read())
    if 'tenant' not in jsondata:
        sys.stderr.write(
            'tenant, token, site_name, fleet_name inputs required')
        sys.exit(1)
    if 'token' not in jsondata:
        sys.stderr.write(
            'tenant, token, site_name, fleet_name inputs required')
        sys.exit(1)
    if 'site_name' not in jsondata:
        sys.stderr.write(
            'tenant, token, site_name, fleet_name inputs required')
        sys.exit(1)
    if 'fleet_name' not in jsondata:
        sys.stderr.write(
            'tenant, token, site_name, fleet_name inputs required')
        sys.exit(1)
    if 'internal_networks' not in jsondata:
        jsondata['internal_networks'] = []
    if 'consul_servers' not in jsondata:
        jsondata['consul_servers'] = []
    if 'ca_cert_encoded' not in jsondata:
        jsondata['ca_cert_encoded'] = ""
    tenant_id = get_tenant_id(jsondata['tenant'], jsondata['token'])
    site_token = assure_site_token(
        jsondata['tenant'], jsondata['token'], jsondata['site_name'])
    fleet_label = assure_fleet(
        jsondata['tenant'], jsondata['token'], jsondata['fleet_name'],
        tenant_id, json.loads(jsondata['internal_networks']))
    assure_service_discovery(
        jsondata['tenant'], jsondata['token'], jsondata['site_name'],
        tenant_id, json.loads(jsondata['consul_servers']), jsondata['ca_cert_encoded']
    )
    jsondata['site_token'] = site_token
    jsondata['fleet_label'] = fleet_label
    sys.stdout.write(json.dumps(jsondata))


if __name__ == '__main__':
    main()
