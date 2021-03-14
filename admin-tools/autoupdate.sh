#!/usr/bin/env bash

set -Eeuo pipefail

[[ "${BASH_VERSINFO[0]}" -lt 5 ]] && echo "Bash >= 5 required" && exit 1

readonly DEPENDENCIES=()
readonly SCRIPT_DIR=$(dirname "$(readlink -f "${0}")")
readonly REPO_ROOT=$(dirname "${SCRIPT_DIR}")
readonly UTIL_SCRIPT="${REPO_ROOT}/util.sh"
readonly VARS_SCRIPT="${REPO_ROOT}/vars.sh"
readonly SCRIPT_NAME=$(basename "${0}")
readonly UPDATE_LOG="${REPO_ROOT}/.update-log"

# shellcheck source=util.sh
. "${UTIL_SCRIPT}"

# shellcheck source=vars.example.sh
. "${VARS_SCRIPT}"

function show_usage() {
    printf "Usage: %s [OPTION...]\n" "${SCRIPT_NAME}" >&2
    printf "  -c, --check\t\tCheck for updates without installing\n" >&2
    printf "  -r, --reboot\t\tPing health check and reboot\n" >&2
    printf "  -s, --skip\t\tSkip the next autoupdate\n" >&2
    printf "  -h, --help\t\tShow this help message then exit\n" >&2
}

function parse_commandline() {

    while [ "${#}" -gt "0" ]; do
        local consume=1

        case "${1}" in
            -c|--check)
                ARG_CHECK="true"
            ;;
            -r|--reboot)
                ARG_REBOOT="true"
            ;;
            -s|--skip)
                ARG_SKIP="true"
            ;;
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

function do_check() {

    # Exits with code 1 if we need to send an email to the admin
    # Exits with code 0 if no action is needed.
    # Save all output from this function and send it to the admin

    local send_email=1
    local no_action_needed=0

    if /usr/local/bin/checknews; then
        news_result="${send_email}" # New articles published. `checknews` already dumped some output saying as much.
    else
        news_result="${no_action_needed}" # No new articles. `checknews` already dumped some output saying as much.
    fi

    if /usr/bin/checkupdates; then
        echo "Pending updates will be installed within the next few days."
        updates_result="${send_email}"
    else
        if [ "${?}" -eq 2 ]; then
            echo "No pending updates."
            updates_result="${no_action_needed}"
        else
            echo "Unexpected error checking for updates."
            updates_result="${send_email}"
        fi
    fi

    if [ "${news_result}" -eq "${send_email}" ] || [ "${updates_result}" -eq "${send_email}" ]; then
        return "${send_email}"
    else
        return "${no_action_needed}"
    fi

}

if is_set "${ARG_CHECK+x}"; then
    if do_check > "${UPDATE_LOG}" 2>&1; then
        echo "No unread Arch news articles and no pending updates."
    else
        send_admin_email "Prepare for Auto-Update" < "${UPDATE_LOG}"
        echo "Email sent to administrator."
    fi

    exit 0
fi

function ping_url() {
    test "${#}" -eq 1 || panic "Expecting 1 parameter: URL to ping"
    curl --proto '=https' --tlsv1.2 \
        --silent \
        --show-error \
        --fail \
        "${1}" > /dev/null 2>&1 || true
}

function do_update() {

    # Do container and pacman updates separately. Leaving the riskier pacman
    # update for the end seems more safe.
    /usr/local/bin/server-cmd --container-update
    /usr/local/bin/server-cmd --pacman-update
}

function ping_and_reboot() {
    ping_url "${HEALTHCHECK_AUTOUPDATE_URL}"
    systemctl reboot
}

if is_set "${ARG_REBOOT+x}"; then
    ping_and_reboot
    exit 0
fi

if is_set "${ARG_SKIP+x}"; then
    set_checkpoint "autoupdate-skip"
    echo "The next ${SCRIPT_NAME} will only ping the health check."
    exit 0
fi

if is_checkpoint_set "autoupdate-skip"; then
    unset_checkpoint "autoupdate-skip"
    ping_url "${HEALTHCHECK_AUTOUPDATE_URL}"
    echo "Skipping automatic update as requested."
    exit 0
fi

ping_url "${HEALTHCHECK_AUTOUPDATE_START_URL}"

if do_update > "${UPDATE_LOG}" 2>&1; then
    send_admin_email "Auto-Update Success" < "${UPDATE_LOG}"
    ping_and_reboot
else
    send_admin_email "Auto-Update Attention Required" < "${UPDATE_LOG}"
fi
