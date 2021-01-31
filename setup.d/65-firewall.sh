#!/usr/bin/env bash

is_unset_checkpoint "firewall-config" || return 0

is_installed firewall-cmd || install_package firewalld
enable_and_start firewalld

function run_firewall_cmd() {
    firewall-cmd --permanent "${@}" > /dev/null
}

function add_port() {
    run_firewall_cmd --zone "${1}" --add-port "${2}"
}

function add_service() {
    run_firewall_cmd --zone "${1}" --add-service "${2}"
}

function remove_service() {
    run_firewall_cmd --zone "${1}" --remove-service "${2}"
}

add_port public "${SSH_SERVICE_PORT}/tcp"
add_port public "${WG_SERVICE_PORT}/udp"

# Nginx
add_service public http
add_service public https
add_port public 8448/tcp # Matrix federation

# TURN
add_port public 3478/tcp
add_port public "${TURN_MIN_PORT}-${TURN_MAX_PORT}/udp"

# Disable unused services on public interface that come configured by default
remove_service public dhcpv6-client
remove_service public ssh

# Apply the public zone to our external interface
run_firewall_cmd --zone public --change-interface "${NET_PRIMARY_INTERFACE}"

# Create a new zone for our WireGuard VPN:
run_firewall_cmd --new-zone vpn
add_service vpn dns

# Enable masquerading (NAT) from WireGuard to the external interface
run_firewall_cmd --new-policy vpn-nat
run_firewall_cmd --policy vpn-nat --add-ingress-zone vpn
run_firewall_cmd --policy vpn-nat --add-egress-zone public
run_firewall_cmd --policy vpn-nat --add-masquerade

# Apply the "vpn" zone to our WireGuard interface
run_firewall_cmd --zone vpn --change-interface wg0

firewall-cmd --reload

set_checkpoint "firewall-config"
