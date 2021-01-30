#!/usr/bin/env bash

function file_contains() {
    test "${#}" -eq 2 || panic "Expecting two arguments: pattern and file path"

    local pattern="${1}"
    local file_path="${2}"

    if [ -f "${file_path}" ]; then
        grep "${pattern}" "${file_path}" > /dev/null
    else
        false # File does not exist in the first place
    fi

}

test -f "/etc/subuid" || place_template "etc/subuid"
test -f "/etc/subgid" || place_template "etc/subgid"

function install_podman() {

    install_package crun podman

    read -r -p "Podman was installed. You won't be able to start any containers without a reboot. Reboot now? (y/N): " decision

    if [ "${decision}" == "y" ] || [ "${decision}" == "Y" ]; then
        systemctl reboot
    else
        false # Cause the script to stop
    fi
}

is_installed podman || install_podman
