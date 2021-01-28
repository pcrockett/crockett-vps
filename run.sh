#!/usr/bin/env bash

set -Eeuo pipefail

[[ "${BASH_VERSINFO[0]}" -lt 5 ]] && echo "Bash >= 5 required" && exit 1

readonly DEPENDENCIES=(sudo nano uniq)
readonly SCRIPT_DIR=$(dirname "$(readlink -f "${0}")")
readonly UTIL_SCRIPT="${SCRIPT_DIR}/util.sh"
readonly VARS_SCRIPT="${SCRIPT_DIR}/vars.sh"
readonly SETUP_DIR="${SCRIPT_DIR}/setup.d"
readonly SCRIPT_NAME=$(basename "${0}")

# shellcheck source=util.sh
. "${UTIL_SCRIPT}"

is_root || panic "Must run this script as root."

function show_usage() {
    printf "Usage: %s [OPTION...]\n" "${SCRIPT_NAME}" >&2
    printf "  -n, --update-nginx\tUpdate Nginx configuration\n" >&2
    printf "  -m, --update-matrix\tUpdate Matrix configuration\n" >&2
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
            -n|--update-nginx)
                ARG_UPDATE_NGINX="true"
            ;;
            -m|--update-matrix)
                ARG_UPDATE_MATRIX="true"
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

if is_set "${ARG_UPDATE_NGINX+x}"; then
    unset_checkpoint "${CHECKPOINT_NGINX_CONF}"
fi

if is_set "${ARG_UPDATE_MATRIX+x}"; then
    unset_checkpoint "${CHECKPOINT_MATRIX_CONF}"
fi

for dep in "${DEPENDENCIES[@]}"; do
    is_installed "${dep}" || panic "Missing '${dep}'"
done

if [ ! -f "${VARS_SCRIPT}" ]; then
    example_vars="${SCRIPT_DIR}/vars.example.sh"
    cp "${example_vars}" "${VARS_SCRIPT}"
    nano "${VARS_SCRIPT}"
fi

# shellcheck source=vars.sh
. "${VARS_SCRIPT}"

readarray -d '' setup_scripts < <(find "${SETUP_DIR}" -maxdepth 1 -mindepth 1 -type f -name "*.sh" -print0 | sort --zero-terminated)
for setup_script in "${setup_scripts[@]}"
do
    # shellcheck source=/dev/null
    . "${setup_script}"
done
