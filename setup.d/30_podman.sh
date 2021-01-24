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

if file_contains "${UNPRIVILEGED_USER}" "/etc/subuid"; then
    place_template "etc/subuid"
fi

if file_contains "${UNPRIVILEGED_USER}" "/etc/subgid"; then
    place_template "etc/subgid"
fi

function install_podman() {
    yes | pacman --sync crun podman
}

is_installed podman || install_podman
