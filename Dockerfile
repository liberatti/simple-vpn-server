FROM rockylinux:8 as main

ENV EASYRSA_VERSION 3.1.7

RUN dnf -y install epel-release \
 && dnf -y install git wget openvpn kmod iptables \
 && dnf clean all

RUN wget https://github.com/OpenVPN/easy-rsa/releases/download/v$EASYRSA_VERSION/EasyRSA-$EASYRSA_VERSION.tgz \
 && mkdir -p /opt/easy-rsa/ \
 && tar xzf EasyRSA-$EASYRSA_VERSION.tgz -C /opt/easy-rsa/ --strip-components 1 \
 && rm -f EasyRSA-$EASYRSA_VERSION.tgz \
 && chown -R root:root /opt/easy-rsa/

COPY scripts/* /
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /*.sh

ENTRYPOINT '/docker-entrypoint.sh'