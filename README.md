# Simple VPN server

It's a full network tunneling VPN software solution that integrates OpenVPN server capabilities and enterprise management capabilities.

## Host Configuration
Before diving into the container setup, ensure the following configurations on your host machine:

### Enable the TUN kernel module:
The TUN module is a kernel driver that allows user-space programs to create virtual network interfaces, which can be used to transport network traffic securely between two points.

```
modprobe tun
```

### Enable Ip forward
If your container will forward requests, modify /etc/sysctl.conf:

```
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
```

## Executing container
Container VPN service will need to know its publication IP and port to pre-build client configuration:

```
docker volume create vpn_config
docker run --privileged -p 1194:1194 \
    -e SERVER_NAME="myserver" \
    -e SUBNET="10.8.0.0 255.255.255.0" \
    -e PUBLIC_IP=192.168.25.1 \
    -e PUBLIC_PORT=1194 \
    -v vpn_config:/etc/openvpn \
    --name openvpn-server \
    liberatti/simple-vpn-server:1.0
```

## Creating client configuration

The container has a utility to create new client configs. The following command will create a certificate and client config to stdout:

```
docker exec -it openvpn-server /add-client.sh client01
```

Depending on the container network, it may also be necessary to add a route mapping to the client config:

```
route 172.17.0.0 255.255.255.0
```

## License Terms

This product utilizes OpenVPN, an open-source software application that provides a secure, point-to-point or site-to-site connection in a routed or bridged configuration. OpenVPN is developed and maintained by the OpenVPN Project.

### Overview

The GNU General Public License (GPL) is an open-source software license developed by the Free Software Foundation (FSF). It is designed to ensure the freedom to use, modify, and distribute software while preserving user rights.

### Full License Text

For the complete text of the GNU General Public License, refer to the [official GPL page](https://www.gnu.org/licenses/gpl.html).


### OpenVPN Project

- **Website:** [OpenVPN Project](https://openvpn.net/)
- **GitHub Repository:** [OpenVPN on GitHub](https://github.com/OpenVPN)