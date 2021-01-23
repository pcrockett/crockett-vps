#!/usr/bin/env bash

set -Eeuo pipefail

[[ "${BASH_VERSINFO[0]}" -lt 4 ]] && echo "Bash >= 4 required" && exit 1

readonly REPO_ROOT=$(dirname "$(readlink -f "${0}")")
export REPO_ROOT

readonly CHECKPOINTS_DIR="${REPO_ROOT}/.checkpoints"
test -d "${CHECKPOINTS_DIR}" || mkdir "${CHECKPOINTS_DIR}" > /dev/null

function panic() {
    >&2 echo "Fatal: ${*}"
    exit 1
}
export panic

function is_installed() {
    command -v "${1}" >/dev/null 2>&1
}
export is_installed

function is_set() {
    # Use this like so:
    #
    #     is_set "${VAR_NAME+x}" || show_usage_and_exit
    #
    # https://stackoverflow.com/a/13864829

    test ! -z "${1}"
}
export is_set

function is_root() {
    test "$(id -u)" -eq 0
}
export is_root

function test_checkpoint() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Checkpoint name"
    test ! -f "${CHECKPOINTS_DIR}/${1}"
}
export test_checkpoint

function set_checkpoint() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Checkpoint name"
    touch "${CHECKPOINTS_DIR}/${1}"
}
export set_checkpoint
