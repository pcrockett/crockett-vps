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
    printf "  -s, --skip-next\tPerform update, but skip the next one\n" >&2
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
            -s|--skip-next)
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

function pending_update_check() {

    # Exits with code 1 if we need to send an email to the admin
    # Exits with code 0 if no action is needed.
    # Save all output from this function and send it to the admin

    local update_is_pending=1
    local no_new_updates=0

    if /usr/local/bin/checknews; then
        news_result="${update_is_pending}" # New articles published. `checknews` already dumped some output saying as much.
    else
        news_result="${no_new_updates}" # No new articles. `checknews` already dumped some output saying as much.
    fi

    if /usr/bin/checkupdates; then
        echo "Pending updates will be installed within the next few days."
        updates_result="${update_is_pending}"
    else
        if [ "${?}" -eq 2 ]; then
            echo "No pending updates."
            updates_result="${no_new_updates}"
        else
            echo "Unexpected error checking for updates."
            updates_result="${update_is_pending}"
        fi
    fi

    if [ "${news_result}" -eq "${update_is_pending}" ] || [ "${updates_result}" -eq "${update_is_pending}" ]; then
        return "${update_is_pending}"
    else
        return "${no_new_updates}"
    fi

}

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

    if /usr/local/bin/checknews; then
        echo "WARNING: Skipping pacman update." # checknews already dumped some output explaining why
    else
        /usr/local/bin/server-cmd --pacman-update
    fi

    if is_set "${ARG_SKIP+x}"; then
        # Confirm to the admin that we won't update next time.
        echo "--skip-next: The next ${SCRIPT_NAME} will only ping the health check."
    fi
}

function ping_and_reboot() {
    ping_url "${HEALTHCHECK_AUTOUPDATE_URL}"
    systemctl reboot
}

if is_checkpoint_set "autoupdate-skip"; then
    unset_checkpoint "autoupdate-skip"
    ping_url "${HEALTHCHECK_AUTOUPDATE_URL}"
    echo "Skipping automatic update as requested. Run ${SCRIPT_NAME} again to continue."
    exit 0
fi

if is_set "${ARG_SKIP+x}"; then
    set_checkpoint "autoupdate-skip"
    echo "The next ${SCRIPT_NAME} will only ping the health check."
fi

if is_set "${ARG_CHECK+x}"; then
    if pending_update_check > "${UPDATE_LOG}" 2>&1; then
        echo "No unread Arch news articles and no pending updates."
    else
        send_admin_email "Prepare for Auto-Update" < "${UPDATE_LOG}"
        echo "Email sent to administrator."
    fi
fi

if is_set "${ARG_REBOOT+x}"; then
    ping_and_reboot
fi

if is_set "${ARG_REBOOT+x}" || is_set "${ARG_CHECK+x}"; then
    exit 0 # User doesn't want to do an actual update.
fi

echo "Auto-update starting. Output will be sent to administrator via email."

ping_url "${HEALTHCHECK_AUTOUPDATE_START_URL}"

if do_update > "${UPDATE_LOG}" 2>&1; then
    send_admin_email "Auto-Update Success" < "${UPDATE_LOG}"
    ping_and_reboot
else
    send_admin_email "Auto-Update Attention Required" < "${UPDATE_LOG}"
fi
