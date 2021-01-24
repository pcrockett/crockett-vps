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

function install_git() {
    yes | pacman --sync git
}

is_installed git || install_git

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
