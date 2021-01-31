#!/usr/bin/env bash

value_exists "wg-private-key" || panic "Value wg-private-key is not set yet."
wg_private_key="$(get_value "wg-private-key")"

value_exists "wg-peer-config" || set_value "wg-peer-config" ""
peer_config="$(get_value "wg-peer-config")"

cat << EOF
[Interface]
PrivateKey = ${wg_private_key}
Address = ${WG_NETWORK_PART}.1/24
ListenPort = ${WG_SERVICE_PORT}
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ${NET_PRIMARY_INTERFACE} -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ${NET_PRIMARY_INTERFACE} -j MASQUERADE
${peer_config}

EOF
