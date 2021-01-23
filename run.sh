#!/usr/bin/env bash

set -Eeuo pipefail

[[ "${BASH_VERSINFO[0]}" -lt 5 ]] && echo "Bash >= 5 required" && exit 1

readonly DEPENDENCIES=(sudo)
readonly SCRIPT_DIR=$(dirname "$(readlink -f "${0}")")
readonly UTIL_SCRIPT="${SCRIPT_DIR}/util.sh"
readonly SETUP_DIR="${SCRIPT_DIR}/setup.d"
readonly SCRIPT_NAME=$(basename "${0}")

# shellcheck source=util.sh
. "${UTIL_SCRIPT}"

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

readarray -d '' setup_scripts < <(find "${SETUP_DIR}" -maxdepth 1 -mindepth 1 -type f -name "*.sh" -print0 | sort --zero-terminated)
for setup_script in "${setup_scripts[@]}"
do
    # shellcheck source=/dev/null
    . "${setup_script}"
done
