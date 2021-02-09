#!/usr/bin/env bash

set -Eeuo pipefail

[[ "${BASH_VERSINFO[0]}" -lt 5 ]] && echo "Bash >= 5 required" && exit 1

readonly DEPENDENCIES=(curl xq)
readonly SCRIPT_DIR=$(dirname "$(readlink -f "${0}")")
readonly REPO_ROOT=$(dirname "${SCRIPT_DIR}")
readonly UTIL_SCRIPT="${REPO_ROOT}/util.sh"
readonly SCRIPT_NAME=$(basename "${0}")
readonly VAL_LAST_PUB_DATE="last-news-pub-date"

# shellcheck source=util.sh
. "${UTIL_SCRIPT}"

function show_usage() {
    printf "Usage: %s [OPTION...]\n" "${SCRIPT_NAME}" >&2
    printf "  -r, --mark-read\t\tMark the latest article as \"read\"\n" >&2
    printf "  -h, --help\t\t\tShow this help message then exit\n" >&2
}

function parse_commandline() {

    while [ "${#}" -gt "0" ]; do
        local consume=1

        case "${1}" in
            -r|--mark-read)
                ARG_MARK_READ="true"
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

latest_pub_date="$(curl --silent https://archlinux.org/feeds/news/ | xq -r .rss.channel.item[0].pubDate)"

if is_set "${ARG_MARK_READ+x}"; then
    set_value "${VAL_LAST_PUB_DATE}" "${latest_pub_date}"
    exit 0
fi

if value_exists "${VAL_LAST_PUB_DATE}"; then
    last_pub_date="$(get_value "${VAL_LAST_PUB_DATE}")"
else
    last_pub_date="NA"
fi

if [ "${latest_pub_date}" != "${last_pub_date}" ]; then
    echo "New Arch news article published. See https://archlinux.org/news/ for details."
    exit 0
else
    echo "No new articles."
    exit 1
fi
