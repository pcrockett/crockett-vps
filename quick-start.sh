#!/usr/bin/env bash

set -Eeuo pipefail

[[ "${BASH_VERSINFO[0]}" -lt 5 ]] && echo "Bash >= 5 required" && exit 1

function is_root() {
    test "$(id -u)" -eq 0
}

function panic() {
    >&2 echo "Fatal: ${*}"
    exit 1
}

is_root || panic "Must be run as root."

function is_installed() {
    command -v "${1}" >/dev/null 2>&1
}

function install_package() {

    test "${#}" -ge 1 || panic "Expecting at least 1 argument: Package name(s)"

    # pacman has some weird exit codes. However we know two things:
    #
    # * pacman returns 0 or any number of other exit codes for "success"
    # * pacman returns 1 for "error"
    #

    if yes | pacman --sync "${@}"; then
        true
    else
        test "${?}" -ne 1
    fi
}

is_installed git || install_package git

checkout_dir="/root/de.crockett.network"

if [ -d "${checkout_dir}" ]; then
    pushd "${checkout_dir}" > /dev/null
    git pull
else
    git clone https://github.com/pcrockett/de.crockett.network.git "${checkout_dir}"
    pushd "${checkout_dir}" > /dev/null
fi

./run.sh

popd > /dev/null
