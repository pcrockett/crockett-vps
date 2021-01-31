#!/usr/bin/env bash

cat << EOF
[Interface]
PrivateKey = ${WG_PRIVATE_KEY}
Address = ${WG_NETWORK_PART}.1/24
ListenPort = ${WG_SERVICE_PORT}
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ${NET_PRIMARY_INTERFACE} -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ${NET_PRIMARY_INTERFACE} -j MASQUERADE

# TODO: Set up peers, something like this:
#
# [Peer]
# # \${DEVICE_DESCRIPTION}
# PublicKey = \${DEVICE_PUBLIC_KEY}
# AllowedIPs = \${WG_NETWORK_PART}.\${DEVICE_NUMBER}/32

EOF
