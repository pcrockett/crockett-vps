#!/usr/bin/env bash

is_unset_checkpoint "firewall-config" || return 0

is_installed firewall-cmd || install_package firewalld
enable_and_start firewalld

function add_port() {
    firewall-cmd --zone=public --add-port "${1}" --permanent
}

function add_service() {
    firewall-cmd --zone=public --add-service "${1}" --permanent
}

add_port "${SSH_SERVICE_PORT}/tcp"
add_port "${WG_SERVICE_PORT}/udp"

# Nginx
add_service http
add_service https
add_port "8448/tcp" # Matrix federation

# TURN
add_port "3478/tcp"
add_port "${TURN_MIN_PORT}-${TURN_MAX_PORT}/udp"

# Disable unused services on public interface that come configured by default
firewall-cmd --zone=public --remove-service dhcpv6-client
firewall-cmd --zone=public --remove-service ssh

firewall-cmd --zone public --change-interface "${NET_PRIMARY_INTERFACE}"

set_checkpoint "firewall-config"
