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
${peer_config}

EOF
