#!/bin/bash

export PKI=/etc/openvpn/pki
export EASYRSA_BATCH=1

if [[ -z "$SERVER_NAME" ]];then
    export SERVER_NAME=myserver.local
fi

/opt/easy-rsa/easyrsa --batch --pki=$PKI --days=3650 revoke "$1"
/opt/easy-rsa/easyrsa --batch --pki=$PKI --days=3650 gen-crl