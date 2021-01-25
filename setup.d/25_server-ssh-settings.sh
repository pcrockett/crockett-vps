#!/usr/bin/env bash

is_unset_checkpoint "server-ssh-settings" || return 0

echo "Setting up SSH server settings..."

# Remove all default host keys and regenerate from scratch
rm /etc/ssh/ssh_host_*key*
ssh-keygen -t rsa -b 4096 -f "/etc/ssh/ssh_host_rsa_key" -N "" < /dev/null
ssh-keygen -t ed25519 -f "/etc/ssh/ssh_host_ed25519_key" -N "" < /dev/null

groupadd ssh-user
usermod --append --groups ssh-user "${UNPRIVILEGED_USER}"
usermod --append --groups ssh-user root

place_file "etc/ssh/sshd_config"

# Restart SSH server without killing the current connection
kill -SIGHUP "$(pgrep -f "sshd -D")"

echo "WARNING: NEW SSH SETTINGS IN PLACE"
echo "Before disconnecting your current session, make sure you can set up a new session."

set_checkpoint "server-ssh-settings"
