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

file_contains "${UNPRIVILEGED_USER}" "/etc/subuid" || place_template "etc/subuid"
file_contains "${UNPRIVILEGED_USER}" "/etc/subgid" || place_template "etc/subgid"
is_installed podman || install_package crun podman
