#!/usr/bin/env python3
import json
import sys
import os
import base64


def create_pkcs12s(ca_cert, ca_key, client_cert, client_key, passphrase):
    wd = os.path.dirname(os.path.realpath(__file__))
    with open("%s/ca_cert.pem" % wd, 'w') as ca_cert_file:
        ca_cert_file.write(ca_cert)
    with open("%s/ca_key.pem" % wd, 'w') as ca_key_file:
        ca_key_file.write(ca_key)
    ca_cmd = "/usr/bin/openssl pkcs12 -export -out %s/ca.p12 -inkey %s/ca_key.pem -in %s/ca_cert.pem -passout pass:%s" % (
        wd, wd, wd, passphrase)
    os.system(ca_cmd)
    with open("%s/ca.p12" % wd, 'rb') as cp12:
        ca_p12_b64 = base64.b64encode(cp12.read())
    with open("%s/client_cert.pem" % wd, 'w') as client_cert_file:
        client_cert_file.write(client_cert)
    with open("%s/client_key.pem" % wd, 'w') as client_key_file:
        client_key_file.write(client_key)
    client_cmd = "/usr/bin/openssl pkcs12 -export -out %s/client.p12 -inkey %s/client_key.pem -in %s/client_cert.pem -passout pass:%s" % (
        wd, wd, wd, passphrase)
    os.system(client_cmd)
    with open("%s/client.p12" % wd, 'rb') as cp12:
        client_p12_b64 = base64.b64encode(cp12.read())
    os.unlink("%s/ca_key.pem" % wd)
    os.unlink("%s/ca_cert.pem" % wd)
    os.unlink("%s/ca.p12" % wd)
    os.unlink("%s/client.p12" % wd)
    os.unlink("%s/client_key.pem" % wd)
    os.unlink("%s/client_cert.pem" % wd)
    return (ca_p12_b64.decode('ascii'), client_p12_b64.decode('ascii'))


def main():
    jsondata = json.loads(sys.stdin.read())
    if not ('ca_cert' in jsondata and jsondata['ca_cert']):
        sys.stderr.write(
            'ca_cert required')
        sys.exit(1)
    if not ('ca_key' in jsondata and jsondata['ca_key']):
        sys.stderr.write(
            'ca_key required')
        sys.exit(1)
    if not ('client_cert' in jsondata and jsondata['client_cert']):
        sys.stderr.write(
            'client_cert required')
        sys.exit(1)
    if not ('client_key' in jsondata and jsondata['client_key']):
        sys.stderr.write(
            'client_key required')
        sys.exit(1)
    if not ('passphrase' in jsondata and jsondata['passphrase']):
        sys.stderr.write(
            'passphrase required')
        sys.exit(1)
    (ca_p12_b64, client_p12_b64) = create_pkcs12s(
        jsondata['ca_cert'],
        jsondata['ca_key'],
        jsondata['client_cert'],
        jsondata['client_key'],
        jsondata['passphrase']
    )
    jsondata['ca_p12_b64'] = ca_p12_b64
    jsondata['client_p12_b64'] = client_p12_b64
    sys.stdout.write(json.dumps(jsondata))


if __name__ == '__main__':
    main()
