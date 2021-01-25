#!/usr/bin/env bash

if [ ! -f ~/.ssh/authorized_keys ]; then
    mkdir --parent ~/.ssh
    echo "${ROOT_SSH_KEY}" > ~/.ssh/authorized_keys
fi

unprivileged_ssh_dir="/home/${UNPRIVILEGED_USER}/.ssh"
if [ ! -f "${unprivileged_ssh_dir}/authorized_keys" ]; then
    mkdir --parent "${unprivileged_ssh_dir}"
    echo "${UNPRIVILEGED_SSH_KEY}" > "${unprivileged_ssh_dir}/authorized_keys"
    chmod -R go-rwx "${unprivileged_ssh_dir}"
    chown -R "${UNPRIVILEGED_USER}:${UNPRIVILEGED_USER}" "${unprivileged_ssh_dir}"
fi
