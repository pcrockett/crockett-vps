#!/usr/bin/env bash

set -Eeuo pipefail

[[ "${BASH_VERSINFO[0]}" -lt 5 ]] && echo "Bash >= 5 required" && exit 1

readonly DEPENDENCIES=(sudo nano uniq)
readonly FULL_SCRIPT_PATH="$(readlink -f "${0}")"
readonly ADMIN_TOOLS_DIR=$(dirname "${FULL_SCRIPT_PATH}")
readonly REPO_ROOT=$(dirname "${ADMIN_TOOLS_DIR}")
readonly UTIL_SCRIPT="${REPO_ROOT}/util.sh"
readonly VARS_SCRIPT="${REPO_ROOT}/vars.sh"
readonly SETUP_DIR="${REPO_ROOT}/setup.d"
readonly SCRIPT_NAME=$(basename "${0}")

# shellcheck source=util.sh
. "${UTIL_SCRIPT}"

is_root || panic "Must run this script as root."

function show_usage() {
    printf "Usage: %s [OPTION...]\n" "${SCRIPT_NAME}" >&2
    printf "  -s, --update-self\t\tPull latest changes from Git remote\n" >&2
    printf "  -n, --nginx-config\t\tUpdate Nginx configuration\n" >&2
    printf "  -p, --pacman-update\t\tCheck pacman for updates\n" >&2
    printf "  -c, --container-update\tUpdate all containers\n" >&2
    printf "  -h, --help\t\t\tShow this help message then exit\n" >&2
}

function show_usage_and_exit() {
    show_usage
    exit 1
}

function parse_commandline() {

    while [ "${#}" -gt "0" ]; do
        local consume=1

        case "${1}" in
            -s|--update-self)
                is_set "${ARG_UPDATE_SELF+x}" || ARG_UPDATE_SELF="true"
            ;;
            --no-update-self)
                # This is only used internally to cancel an "--update-self". It
                # is used only when this script calls itself below.
                ARG_UPDATE_SELF="false"
            ;;
            -n|--nginx-config)
                ARG_UPDATE_NGINX="true"
            ;;
            -p|--pacman-update)
                ARG_PACMAN_UPDATE="true"
            ;;
            -c|--container-update)
                ARG_CONTAINER_UPDATE="true"
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

original_params=("${@}")
parse_commandline "${@}"

if is_set "${ARG_UPDATE_SELF+x}" && test "${ARG_UPDATE_SELF}" == "true"; then
    pushd "${REPO_ROOT}" > /dev/null
    git pull
    popd > /dev/null

    # Re-run this script with the latest changes
    "${FULL_SCRIPT_PATH}" --no-update-self "${original_params[@]}"
    exit "${?}"
fi

if is_set "${ARG_HELP+x}"; then
    show_usage_and_exit
fi

if is_set "${ARG_UPDATE_NGINX+x}"; then
    unset_checkpoint "${CHECKPOINT_NGINX_CONF}"
fi

if is_set "${ARG_PACMAN_UPDATE+x}"; then
    unset_checkpoint "${CHECKPOINT_SYSUPGRADE}"
fi

if is_set "${ARG_CONTAINER_UPDATE+x}"; then
    unset_checkpoint "${CHECKPOINT_CONTAINER_UPDATE}"
fi

for dep in "${DEPENDENCIES[@]}"; do
    is_installed "${dep}" || panic "Missing '${dep}'"
done

if [ ! -f "${VARS_SCRIPT}" ]; then
    example_vars="${REPO_ROOT}/vars.example.sh"
    cp "${example_vars}" "${VARS_SCRIPT}"
    nano "${VARS_SCRIPT}"
fi

# shellcheck source=vars.example.sh
. "${VARS_SCRIPT}"

readarray -d '' setup_scripts < <(find "${SETUP_DIR}" -maxdepth 1 -mindepth 1 -type f -name "*.sh" -print0 | sort --zero-terminated)
for setup_script in "${setup_scripts[@]}"
do
    # shellcheck source=/dev/null
    (. "${setup_script}") # Use subshells so each individual script doesn't pollute our environment
done
