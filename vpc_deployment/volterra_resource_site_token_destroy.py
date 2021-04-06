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
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
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
    except Exception as er:
        sys.stderr.write(
            "Error retrieving site token resources %s\n" % er)
        sys.exit(1)


def remove_fleet(tenant, token, fleet_name):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # Does the site token exist
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/fleets/%s" % (
            tenant, fleet_name)
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        urllib.request.urlopen(request)
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
        urllib.request.urlopen(request)
        return True
    except HTTPError as her:
        if her.code == 404:
            return True
        else:
            sys.stderr.write(
                "Error retrieving feet resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error retrieving fleet resources %s\n" % er)
        sys.exit(1)


def main():
    ap = argparse.ArgumentParser(
        prog='volterra_resource_site_token_destroy',
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
    remove_site_token(args.tenant, args.token, args.site)

    sys.exit(0)


if __name__ == '__main__':
    main()
