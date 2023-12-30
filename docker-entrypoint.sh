#!/bin/bash

export PKI=/etc/openvpn/pki

if [[ -z "$SERVER_NAME" ]];then
    export SERVER_NAME=myserver.local
fi

if [[ -z "$SUBNET" ]];then
    export SUBNET="10.8.0.0 255.255.255.0"
fi

if [[ -z "$PUBLIC_IP" ]];then
    export PUBLIC_IP=172.17.0.1
fi
if [[ -z "$PUBLIC_PORT" ]];then
    export PUBLIC_PORT=1194
fi

create_pki(){
	/opt/easy-rsa/easyrsa --batch --pki=$PKI init-pki
	/opt/easy-rsa/easyrsa --batch --pki=$PKI build-ca nopass
	/opt/easy-rsa/easyrsa --batch --pki=$PKI --days=3650 build-server-full $SERVER_NAME nopass
	/opt/easy-rsa/easyrsa --batch --pki=$PKI --days=3650 gen-crl
	openvpn --genkey --secret $PKI/tc.key
	openssl dhparam -out $PKI/dh.pem 2048
	chown nobody:nobody $PKI
}

if [[ ! -e /etc/openvpn/server/server.conf ]]; then
    mkdir -p /etc/openvpn/server/
    create_pki
    cat >/etc/openvpn/server/server.conf <<EOL
    ifconfig-pool-persist /etc/openvpn/ipp.txt 
    port 1194
    proto tcp
    dev tun
    ca $PKI/ca.crt
    cert $PKI/issued/$SERVER_NAME.crt
    key $PKI/private/$SERVER_NAME.key
    dh $PKI/dh.pem
    auth SHA512
    tls-crypt $PKI/tc.key
    topology subnet
    server $SUBNET
	keepalive 10 120
    user nobody
    group nobody
    persist-key
    persist-tun
    verb 3
    crl-verify $PKI/crl.pem
EOL
    cat >/etc/openvpn/server/client-common.ovpn <<EOL
client
dev tun
proto tcp
remote $PUBLIC_IP $PUBLIC_PORT
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA512
verb 3
EOL
    echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-openvpn-forward.conf
fi

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
cd /etc/openvpn/server/
openvpn --config /etc/openvpn/server/server.conf