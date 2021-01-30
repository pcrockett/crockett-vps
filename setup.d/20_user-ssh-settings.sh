#!/usr/bin/env bash

if [ ! -f ~/.ssh/authorized_keys ]; then
    mkdir --parent ~/.ssh
    echo "${ROOT_SSH_KEY}" > ~/.ssh/authorized_keys
fi

# Note that adding SSH keys to each user's authorized_keys file does NOT give
# anyone SSH access. SSH access is controlled by the ssh-user group.

for user in "${UNPRIVILEGED_USERS[@]}"
do

    unprivileged_ssh_dir="/home/${user}/.ssh"
    if [ ! -f "${unprivileged_ssh_dir}/authorized_keys" ]; then
        mkdir --parent "${unprivileged_ssh_dir}"
        echo "${UNPRIVILEGED_SSH_KEY}" > "${unprivileged_ssh_dir}/authorized_keys"
        chmod -R go-rwx "${unprivileged_ssh_dir}"
        chown -R "${user}:${user}" "${unprivileged_ssh_dir}"
    fi

done
