#!/usr/bin/env bash

set -Eeuo pipefail

[[ "${BASH_VERSINFO[0]}" -lt 5 ]] && echo "Bash >= 5 required" && exit 1

readonly DEPENDENCIES=()
readonly SCRIPT_DIR=$(dirname "$(readlink -f "${0}")")
readonly UTIL_SCRIPT="${SCRIPT_DIR}/util.sh"
readonly VARS_SCRIPT="${SCRIPT_DIR}/vars.sh"
readonly SCRIPT_NAME=$(basename "${0}")

# shellcheck source=util.sh
. "${UTIL_SCRIPT}"

# is_root || panic "Must run this script as root."

function show_usage() {
    printf "Usage: %s [OPTION...]\n" "${SCRIPT_NAME}\n" >&2
    printf "  -u, --username\tThe username\n" >&2
    printf "  -p, --password\tThe password\n" >&2
    printf "  -a, --admin\t\tAdmin user\n" >&2
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
            -u|--username)
                consume=2
                if is_set "${2+x}"; then
                    ARG_USERNAME="${2}"
                else
                    panic "No username specified."
                fi
            ;;
            -p|--password)
                consume=2
                if is_set "${2+x}"; then
                    ARG_PASSWORD="${2}"
                else
                    panic "No password specified."
                fi
            ;;
            -a|--admin)
                ARG_ADMIN="true"
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

is_set "${ARG_USERNAME+x}" || panic "--username needs to be specified"

function get_password() {
    read -s -r -p "Enter ${ARG_USERNAME}'s password: " ARG_PASSWORD
    echo ""
}

is_set "${ARG_PASSWORD+x}" || get_password

if is_set "${ARG_ADMIN+x}"; then
    admin_param="--admin"
else
    admin_param="--no-admin"
fi

run_unprivileged podman exec --interactive --tty synapse \
    register_new_matrix_user http://localhost:8008 \
    --user "${ARG_USERNAME}" \
    --password "${ARG_PASSWORD}" \
    "${admin_param}" \
    --config /data/homeserver.yaml

