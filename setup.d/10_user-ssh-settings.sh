#!/usr/bin/env bash

unprivileged_ssh_dir="/home/${UNPRIVILEGED_USER}/.ssh"

if is_root; then
    if [ ! -f ~/.ssh/authorized_keys ]; then
        mkdir --parent ~/.ssh
        echo "${ROOT_SSH_KEY}" > ~/.ssh/authorized_keys
    fi

    if [ ! -f "${unprivileged_ssh_dir}/authorized_keys" ]; then
        sudo --login --user "${UNPRIVILEGED_USER}" \
            --preserve-env=UNPRIVILEGED_USER,UNPRIVILEGED_SSH_KEY \
            "$(readlink -f "${0}")"
    fi
else
    mkdir --parent "${unprivileged_ssh_dir}"
    echo "${UNPRIVILEGED_SSH_KEY}" > "${unprivileged_ssh_dir}/authorized_keys"
    chmod -R go-rwx "${unprivileged_ssh_dir}"
fi
