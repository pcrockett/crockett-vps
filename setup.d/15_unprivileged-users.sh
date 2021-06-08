#!/usr/bin/env bash

function mkdir_user() {
    test "${#}" -eq 2 || panic "Expecting 2 arguments: directory path and owning user"
    local path="${1}"
    local user="${2}"

    if [ ! -d "${path}" ]; then
        mkdir "${path}"
        chown "${user}:${user}" "${path}"
    fi
}

for user in "${UNPRIVILEGED_USERS[@]}"
do
    user_home_dir="home/${user}" # Intentionally leaving off first `/`

    test -d "/${user_home_dir}" || create_user "${user}"

    config_dir="${user_home_dir}/.config"
    mkdir_user "/${config_dir}" "${user}"

    container_conf_dir="${config_dir}/containers"
    mkdir_user "/${container_conf_dir}" "${user}"

    place_file "${container_conf_dir}/storage.conf"

    # Start a user manager service for this user at boot. Podman needs this.
    loginctl enable-linger "${user}"
done
