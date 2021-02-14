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

# shellcheck source=vars.example.sh
. "${VARS_SCRIPT}"

function show_usage() {
    printf "Usage: %s [OPTION...]\n" "${SCRIPT_NAME}" >&2
    printf "  -h, --help\t\tShow this help message then exit\n" >&2
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
                show_usage
                exit 1
            ;;
        esac

        shift ${consume}
    done
}

parse_commandline "${@}"

if is_set "${ARG_HELP+x}"; then
    show_usage
    exit 1
fi

for dep in "${DEPENDENCIES[@]}"; do
    is_installed "${dep}" || panic "Missing '${dep}'"
done

function ping_url() {
    test "${#}" -eq 1 || panic "Expecting 1 parameter: URL to ping"
    curl --proto '=https' --tlsv1.2 \
        --silent \
        --show-error \
        --fail \
        "${1}" 2>&1 || true
}

function do_update() {

    # Do container and pacman updates separately. Leaving the riskier pacman
    # update for the end seems more safe.
    /usr/local/bin/server-cmd --container-update 2>&1
    /usr/local/bin/server-cmd --pacman-update 2>&1
}

ping_url "${HEALTHCHECK_AUTOUPDATE_START_URL}"

if pacman_results="$(do_update)"; then
    echo "${pacman_results}" | send_admin_email "Auto-Update Success"
    ping_url "${HEALTHCHECK_AUTOUPDATE_URL}"
    systemctl reboot
else
    echo "${pacman_results}" | send_admin_email "Auto-Update Attention Required"
fi
