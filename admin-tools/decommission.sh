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
    printf "Usage: %s [OPTION...]\n" "${SCRIPT_NAME}" >&2
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
    panic "It looks like this server was never set up in the first place. Nothing to decommission."
fi

# shellcheck source=vars.sh
. "${VARS_SCRIPT}"

function revoke_cert() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Certificate name"
    local cert_name="${1}"
    certbot revoke \
        --cert-name "${cert_name}" \
        --reason cessationofoperation \
        --non-interactive \
        --delete-after-revoke
}

certs_to_revoke=(
    "${DOMAIN_PRIMARY}"
)

for domain in "${certs_to_revoke[@]}"
do
    test ! -f "/etc/letsencrypt/live/${domain}/privkey.pem" \
        || revoke_cert "${domain}"
done
