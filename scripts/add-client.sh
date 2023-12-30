#!/bin/bash

export PKI=/etc/openvpn/pki
export EASYRSA_BATCH=1

if [[ -z "$SERVER_NAME" ]];then
    export SERVER_NAME=myserver.local
fi

/opt/easy-rsa/easyrsa --batch --pki=$PKI --days=3650 build-client-full "$1" nopass 
cat /etc/openvpn/server/client-common.ovpn
echo "<ca>"
cat $PKI/ca.crt
echo "</ca>"
echo "<cert>"
sed -ne '/BEGIN CERTIFICATE/,$ p' $PKI/issued/"$1".crt
echo "</cert>"
echo "<key>"
cat $PKI/private/"$1".key
echo "</key>"
echo "<tls-crypt>"
sed -ne '/BEGIN OpenVPN Static key/,$ p' $PKI/tc.key
echo "</tls-crypt>"
