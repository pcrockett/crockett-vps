#!/usr/bin/env bash

is_unset_checkpoint "server-ssh-settings" || return 0

echo "Setting up SSH server settings..."

# Remove all default host keys and regenerate from scratch
rm /etc/ssh/ssh_host_*key*
ssh-keygen -t rsa -b 4096 -f "/etc/ssh/ssh_host_rsa_key" -N "" < /dev/null
ssh-keygen -t ed25519 -f "/etc/ssh/ssh_host_ed25519_key" -N "" < /dev/null

groupadd ssh-user
usermod --append --groups ssh-user root

place_template "etc/ssh/sshd_config"

firewall_add_port external "${SSH_SERVICE_PORT}/tcp"
firewall_add_port vpn "${SSH_SERVICE_PORT}/tcp"

# We are using a custom port for SSH, so let's remove the service that came configured by default
run_firewall_cmd --zone external --remove-service ssh

# Restart SSH server without killing the current connection
kill -SIGHUP "$(pgrep -f "sshd -D")"

echo "NEW SSH SETTINGS IN PLACE. Before disconnecting your current session, make sure you can set up a new session on port ${SSH_SERVICE_PORT}."
read -r -p "Press enter to continue configuration... "

set_checkpoint "server-ssh-settings"
