#!/usr/bin/env bash

set -Eeuo pipefail

[[ "${BASH_VERSINFO[0]}" -lt 5 ]] && echo "Bash >= 5 required" && exit 1

readonly DEPENDENCIES=()
readonly SCRIPT_DIR=$(dirname "$(readlink -f "${0}")")
readonly REPO_ROOT=$(dirname "${SCRIPT_DIR}")
readonly UTIL_SCRIPT="${REPO_ROOT}/util.sh"
readonly VARS_SCRIPT="${REPO_ROOT}/vars.sh"
readonly SCRIPT_NAME=$(basename "${0}")

# shellcheck source=util.sh
. "${UTIL_SCRIPT}"

is_root || panic "Must run this script as root."

function show_usage() {
    printf "Usage: %s [OPTION...]\n" "${SCRIPT_NAME}\n" >&2
    printf "  -d, --description\tPeer description (for humans)\n" >&2
    printf "  -h, --help\t\tShow this help message then exit\n" >&2
}

function show_usage_and_exit() {
    show_usage
    exit 1
}

function parse_commandline() {

    while [ "${#}" -gt "0" ]; do
        local consume=1

        case "${1}" in
            -d|--description)
                consume=2
                if is_set "${2+x}"; then
                    ARG_DESCRIPTION="${2}"
                else
                    panic "No description specified."
                fi
            ;;
            -h|-\?|--help)
                ARG_HELP="true"
            ;;
            *)
                echo "Unrecognized argument: ${1}"
                show_usage_and_exit
            ;;
        esac

        shift ${consume}
    done
}

parse_commandline "${@}"

if is_set "${ARG_HELP+x}"; then
    show_usage_and_exit
fi

for dep in "${DEPENDENCIES[@]}"; do
    is_installed "${dep}" || panic "Missing '${dep}'"
done

if [ ! -f "${VARS_SCRIPT}" ]; then
    panic "It looks like this server was never set up in the first place. Execute \"run.sh\" first."
fi

# shellcheck source=vars.sh
. "${VARS_SCRIPT}"

is_set "${ARG_DESCRIPTION+x}" || panic "--description needs to be specified"

value_exists "wg-last-peer" || set_value "wg-last-peer" "1"
last_peer_number="$(get_value "wg-last-peer")"
new_peer_number=$(("${last_peer_number}"+1))

test "${new_peer_number}" -lt 255 || panic "Peer limit reached (254)."

value_exists "wg-peer-config" || set_value "wg-peer-config" ""
old_peer_server_config="$(get_value "wg-peer-config")"

peer_private_key=$(wg genkey)
peer_public_key=$(echo "${peer_private_key}" | wg pubkey)

new_peer_server_config=$(cat << EOF
${old_peer_server_config}

[Peer]
# ${ARG_DESCRIPTION}
PublicKey = ${peer_public_key}
AllowedIPs = ${WG_NETWORK_PART}.${new_peer_number}/32

EOF
)

set_value "wg-peer-config" "${new_peer_server_config}"
set_value "wg-last-peer" "${new_peer_number}"

# Regenerate server config with new peer
place_template "etc/wireguard/wg0.conf"

# Now let's generate the new config for the new peer
server_public_key="$(get_value "wg-public-key")"

value_exists "external-ip" || set_value "external-ip" "$(curl -4 https://icanhazip.com/)"
external_ip="$(get_value "external-ip")"

new_peer_client_config=$(cat << EOF
[Interface]
PrivateKey = ${peer_private_key}
Address = ${WG_NETWORK_PART}.${new_peer_number}/32
DNS = ${WG_NETWORK_PART}.1
# MTU = 1370

[Peer]
PublicKey = ${server_public_key}
Endpoint = ${external_ip}:${WG_SERVICE_PORT}
AllowedIPs = 0.0.0.0/0, ::/0
# PersistentKeepalive = 25
EOF
)

is_installed qrencode || install_package qrencode

echo "${new_peer_client_config}" | qrencode --type utf8
echo ""
echo "-------------------------------------"
echo "${new_peer_client_config}"
echo "-------------------------------------"
echo ""
echo "You have two options:"
echo "1. Use the above QR code to add a WireGuard tunnel to mobile devices."
echo "2. Use the above text to add a WireGuard tunnel to non-mobile devices."

systemctl restart wg-quick@wg0
