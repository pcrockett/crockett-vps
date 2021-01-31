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

# Network topology:
#
# * Our Internet-facing interface will be in the "external" zone (which comes
#   pre-configured with firewalld)
# * Our WireGuard interface will be in the "vpn" zone (which we will create)
# * We will do NAT forwarding from the vpn to the external zone
#

##### CONFIGURE ZONES #####
run_firewall_cmd --new-zone vpn

# Disable unused services on external interface that come configured by default
remove_service external ssh # We are using a custom port for SSH

# Enable masquerading (NAT) from WireGuard to the external interface
# Stole much of this from https://firewalld.org/2020/09/policy-objects-filtering-container-and-vm-traffic
run_firewall_cmd --new-policy vpn-nat
run_firewall_cmd --policy vpn-nat --add-ingress-zone vpn
run_firewall_cmd --policy vpn-nat --add-egress-zone external
run_firewall_cmd --policy vpn-nat --add-masquerade

##### CONFIGURE SERVICES #####

# SSH
add_port external "${SSH_SERVICE_PORT}/tcp"
add_port vpn "${SSH_SERVICE_PORT}/tcp"

# WireGuard
add_port external "${WG_SERVICE_PORT}/udp"

# Nginx
add_service external http
add_service external https
add_port external 8448/tcp # Matrix federation only necessary on external
add_service vpn http
add_service vpn https

# TURN
add_port external 3478/tcp
add_port external "${TURN_MIN_PORT}-${TURN_MAX_PORT}/udp"
add_port vpn 3478/tcp # TURN
add_port vpn "${TURN_MIN_PORT}-${TURN_MAX_PORT}/udp"

# DNS
add_service vpn dns # We only want to run a DNS server for our WireGuard peers

# Apply zones to interfaces
run_firewall_cmd --zone external --change-interface "${NET_PRIMARY_INTERFACE}"
run_firewall_cmd --zone vpn --change-interface wg0

firewall-cmd --reload

set_checkpoint "firewall-config"
