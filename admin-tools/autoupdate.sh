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
    printf "  -c, --check\t\tCheck for updates without installing\n" >&2
    printf "  -h, --help\t\tShow this help message then exit\n" >&2
}

function parse_commandline() {

    while [ "${#}" -gt "0" ]; do
        local consume=1

        case "${1}" in
            -c|--check)
                ARG_CHECK="true"
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
        news_result="${no_action_needed}" # No new articles
    else
        news_result="${send_email}" # New articles published
    fi

    if /usr/bin/checkupdates; then
        updates_result="${send_email}" # Updates are available
    else
        if [ "${updates_result}" -eq 2 ]; then
            updates_result="${no_action_needed}" # No new updates are available, nothing to do
        else
            updates_result="${send_email}" # We have some other kind of error
        fi
    fi

    if [ "${news_result}" -eq "${send_email}" ] || [ "${updates_result}" -eq "${send_email}" ]; then
        return "${send_email}"
    else
        return "${no_action_needed}"
    fi

}

if is_set "${ARG_CHECK+x}"; then
    if email_body="$(do_check 2>&1)"; then
        echo "No unread Arch news articles and no pending updates."
    else
        echo "${email_body}" | send_admin_email "Prepare for Auto-Update"
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
        "${1}" 2>&1 || true
}

function do_update() {

    # Do container and pacman updates separately. Leaving the riskier pacman
    # update for the end seems more safe.
    /usr/local/bin/server-cmd --container-update
    /usr/local/bin/server-cmd --pacman-update
}

ping_url "${HEALTHCHECK_AUTOUPDATE_START_URL}"

update_log="${REPO_ROOT}/.update-log"
if do_update > "${update_log}" 2>&1; then
    send_admin_email "Auto-Update Success" < "${update_log}"
    ping_url "${HEALTHCHECK_AUTOUPDATE_URL}"
    systemctl reboot
else
    send_admin_email "Auto-Update Attention Required" < "${update_log}"
fi
