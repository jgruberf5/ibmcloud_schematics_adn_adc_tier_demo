#!/usr/bin/env python3

import sys
import json
import argparse
import urllib.request

from urllib.error import HTTPError


def remove_site_token(tenant, token, site_token_name):
    site_token_name = site_token_name.encode('utf-8').decode('utf-8')
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # Does the site token exist
    try:
        url = "https://%s.console.ves.volterra.io/api/register/namespaces/system/tokens/%s" % (
            tenant, site_token_name)
        headers['volterra-apigw-tenant'] = tenant
        headers['content-type'] = 'application/json'
        data = {
            'fail_if_referred': False,
            'name': site_token_name,
            'namespace': 'system'
        }
        data = json.dumps(data)
        request = urllib.request.Request(
            url=url, headers=headers, data=bytes(data.encode('utf-8')), method='DELETE')
        urllib.request.urlopen(request)
        return True
    except HTTPError as her:
        if her.code == 404:
            return True
        else:
            sys.stderr.write(
                "Error deleting site tokens resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error deleting site token resources %s - %s\n" % (url, er))
        sys.exit(1)


def remove_virutal_network(tenant, token, fleet_name):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # Does the site token exist
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/virtual_networks/%s" % (
            tenant, fleet_name)
        headers['volterra-apigw-tenant'] = tenant
        headers['content-type'] = 'application/json'
        data = {
            'fail_if_referred': False,
            'name': fleet_name,
            'namespace': 'system'
        }
        data = json.dumps(data)
        request = urllib.request.Request(
            url=url, headers=headers, data=bytes(data.encode('utf-8')), method='DELETE')
        response = urllib.request.urlopen(request)
        return True
    except HTTPError as her:
        if her.code == 404:
            return True
        else:
            sys.stderr.write(
                "Error deleting virtual_networks resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error deleting virtual_networks resources %s: %s\n" % (url, er))
        sys.exit(1)


def remove_network_connector(tenant, token, fleet_name):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/network_connectors/%s" % (
            tenant, fleet_name)
        headers['volterra-apigw-tenant'] = tenant
        headers['content-type'] = 'application/json'
        data = {
            'fail_if_referred': False,
            'name': fleet_name,
            'namespace': 'system'
        }
        data = json.dumps(data)
        request = urllib.request.Request(
            url=url, headers=headers, data=bytes(data.encode('utf-8')), method='DELETE')
        response = urllib.request.urlopen(request)
        return True
    except HTTPError as her:
        if her.code == 404:
            return True
        else:
            sys.stderr.write(
                "Error deleting network_connectors resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error deleting network_connectors resources %s: %s\n" % (url, er))
        sys.exit(1)


def remove_fleet(tenant, token, fleet_name):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # Does the site token exist
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/fleets/%s" % (
            tenant, fleet_name)
        headers['volterra-apigw-tenant'] = tenant
        headers['content-type'] = 'application/json'
        data = {
            'fail_if_referred': False,
            'name': fleet_name,
            'namespace': 'system'
        }
        data = json.dumps(data)
        request = urllib.request.Request(
            url=url, headers=headers, data=bytes(data.encode('utf-8')), method='DELETE')
        response = urllib.request.urlopen(request)
        return True
    except HTTPError as her:
        if her.code == 404:
            return True
        else:
            sys.stderr.write(
                "Error deleting fleets resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error deleting fleets resources %s: %s\n" % (url, er))
        sys.exit(1)


def remove_service_discovery(tenant, token, fleet_name):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/discoverys" % tenant
        headers['volterra-apigw-tenant'] = tenant
        headers['content-type'] = 'application/json'
        request = urllib.request.Request(
            url=url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
        for discovery in json.load(response)['items']:
            if discovery['name'].startswith(fleet_name):
                url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/discoverys/%s" % (tenant, discovery['name'])
                data = {
                    'fail_if_referred': False,
                    'name': discovery['name'],
                    'namespace': 'system'
                }
                data = json.dumps(data)
                del_req = urllib.request.Request(url=url, headers=headers, data=bytes(data.encode('utf-8')), method='DELETE')
                del_res = urllib.request.urlopen(del_req)
        return True
    except HTTPError as her:
        if her.code == 404:
            return True
        else:
            sys.stderr.write(
                "Error deleting discovery resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error deleting discovery resources %s: %s\n" % (url, er))
        sys.exit(1)

def main():
    ap = argparse.ArgumentParser(
        prog='volterra_resource_site_destroy',
        usage='%(prog)s.py [options]',
        description='clean up site tokens and fleets on destroy'
    )
    ap.add_argument(
        '--site',
        help='Volterra site name',
        required=True
    )
    ap.add_argument(
        '--fleet',
        help='Volterra fleet name',
        required=True
    )
    ap.add_argument(
        '--tenant',
        help='Volterra site tenant',
        required=True
    )
    ap.add_argument(
        '--token',
        help='Volterra API token',
        required=True
    )
    args = ap.parse_args()

    remove_fleet(args.tenant, args.token, args.fleet)
    remove_virutal_network(args.tenant, args.token, args.fleet)
    remove_network_connector(args.tenant, args.token, args.fleet)
    remove_site_token(args.tenant, args.token, args.site)
    remove_service_discovery(args.tenant, args.token, args.fleet)
    
    sys.exit(0)


if __name__ == '__main__':
    main()
