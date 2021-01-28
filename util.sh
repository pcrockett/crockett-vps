#!/usr/bin/env bash

set -Eeuo pipefail

[[ "${BASH_VERSINFO[0]}" -lt 5 ]] && echo "Bash >= 5 required" && exit 1

readonly REPO_ROOT=$(dirname "$(readlink -f "${0}")")
export REPO_ROOT

readonly WARNING_FILE="${REPO_ROOT}/.pending-warnings"
export WARNING_FILE

readonly CHECKPOINT_NGINX_CONF="nginx-conf"
export CHECKPOINT_NGINX_CONF

readonly CHECKPOINT_MATRIX_CONF="matrix-conf"
export CHECKPOINT_MATRIX_CONF

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

function install_package() {

    test "${#}" -ge 1 || panic "Expecting at least 1 argument: Package name(s)"

    # pacman has some weird exit codes. However we know two things:
    #
    # * pacman returns 0 or any number of other exit codes for "success"
    # * pacman returns 1 for "error"
    #

    warn_when_finished "Software was updated or installed. A reboot may be required."

    if yes | pacman --sync --refresh --sysupgrade "${@}"; then
        true
    else
        test "${?}" -ne 1
    fi
}
export install_package

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

function is_unset_checkpoint() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Checkpoint name"
    test ! -f "${CHECKPOINTS_DIR}/${1}"
}
export is_unset_checkpoint

function set_checkpoint() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Checkpoint name"
    touch "${CHECKPOINTS_DIR}/${1}"
}
export set_checkpoint

function unset_checkpoint() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Checkpoint name"
    checkpoint_path="${CHECKPOINTS_DIR}/${1}"
    if [ -f "${checkpoint_path}" ]; then
        rm "${checkpoint_path}"
    fi
}
export unset_checkpoint

function place_file() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: File path"

    src_path="${REPO_ROOT}/rootfs/${1}"
    dest_path="/${1}"

    if [ -f "${dest_path}" ]; then
        old_path="${dest_path}.old"
        mv "${dest_path}" "${old_path}"
    fi

    cp "${src_path}" "${dest_path}"
}
export place_file

function place_template() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Template path"

    template_src="${REPO_ROOT}/rootfs/${1}.sh"
    test -x "${template_src}" || panic "${template_src} is not executable."

    dest_path="/${1}"
    if [ -f "${dest_path}" ]; then
        old_path="${dest_path}.old"
        mv "${dest_path}" "${old_path}"
    fi

    # shellcheck source=/dev/null
    . "${template_src}" > "${dest_path}"
}
export place_template

function warn_when_finished() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Warning message"
    echo "${1}" >> "${WARNING_FILE}"
}
export warn_when_finished

function run_unprivileged() {
    test "${#}" -ge 1 || panic "Expecting at least 1 argument: Command to run"
    sudo --login --user "${UNPRIVILEGED_USER}" "${@}"
}
export run_unprivileged
