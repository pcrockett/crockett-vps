#!/usr/bin/env bash

set -Eeuo pipefail

[[ "${BASH_VERSINFO[0]}" -lt 5 ]] && echo "Bash >= 5 required" && exit 1

readonly DEPENDENCIES=(curl certbot)
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

certbot renew # TODO: Look at docs to see if we should add any parameters for this
ping_url "${HEALTHCHECK_CERTBOT_RENEW_URL}"
