#!/usr/bin/env bash

set -Eeuo pipefail

[[ "${BASH_VERSINFO[0]}" -lt 4 ]] && echo "Bash >= 4 required" && exit 1

readonly REPO_ROOT=$(dirname "$(readlink -f "${0}")")
export REPO_ROOT

function panic() {
    >&2 echo "Fatal: ${*}"
    exit 1
}

function is_installed() {
    command -v "${1}" >/dev/null 2>&1
}

function is_set() {
    # Use this like so:
    #
    #     is_set "${VAR_NAME+x}" || show_usage_and_exit
    #
    # https://stackoverflow.com/a/13864829

    test ! -z "${1}"
}
