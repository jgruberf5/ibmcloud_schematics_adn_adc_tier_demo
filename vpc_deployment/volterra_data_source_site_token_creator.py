#!/usr/bin/env python3

import sys
import json
import urllib.request

from urllib.error import HTTPError


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


def assure_fleet(tenant, token, fleet_name):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # Does the site token exist
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/fleets/%s" % (
            tenant, fleet_name)
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
        return json.load(response)['spec']['fleet_label']
    except HTTPError as her:
        if her.code == 404:
            url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/fleets" % tenant
            headers['volterra-apigw-tenant'] = tenant
            headers['content-type'] = 'application/json'
            data = {
                "namespace": "system",
                "metadata": {
                    "name": fleet_name,
                    "namespace": "system",
                    "labels": {},
                    "annotations": {},
                    "description": "Fleet provisioning object for %s" % fleet_name,
                    "disable": None
                },
                "spec": {
                    "fleet_label": fleet_name,
                    "volterra_software_version": None,
                    "network_connectors": None,
                    "network_firewall": None,
                    "operating_system_version": None,
                    "outside_virtual_network": None,
                    "inside_virtual_network": None,
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
        else:
            sys.stderr.write(
                "Error retrieving feet resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error retrieving fleet resources %s\n" % er)
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
    site_token = assure_site_token(
        jsondata['tenant'], jsondata['token'], jsondata['site_name'])
    fleet_label = assure_fleet(
        jsondata['tenant'], jsondata['token'], jsondata['fleet_name'])
    jsondata['site_token'] = site_token
    jsondata['fleet_label'] = fleet_label
    sys.stdout.write(json.dumps(jsondata))


if __name__ == '__main__':
    main()
