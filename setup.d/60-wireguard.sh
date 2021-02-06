#!/usr/bin/env bash

is_installed wg-quick || install_package wireguard-tools

if value_not_exists "wg-private-key"; then

    # We haven't set up WireGuard yet.

    private_key=$(wg genkey)
    public_key=$(echo "${private_key}" | wg pubkey)

    set_value "wg-private-key" "${private_key}"
    set_value "wg-public-key" "${public_key}"

    place_template "etc/wireguard/wg0.conf"

    sysctl --write net.ipv4.ip_forward=1 > /dev/null

    enable_and_start "wg-quick@wg0"

    # Enable masquerading (NAT) from WireGuard to the external interface
    # Stole much of this from https://firewalld.org/2020/09/policy-objects-filtering-container-and-vm-traffic
    run_firewall_cmd --new-policy vpn-nat
    run_firewall_cmd --policy vpn-nat --add-ingress-zone vpn
    run_firewall_cmd --policy vpn-nat --add-egress-zone external
    run_firewall_cmd --policy vpn-nat --add-masquerade

    # Actually apply the vpn zone to our new WireGuard interface
    run_firewall_cmd --zone vpn --change-interface wg0

    # Allow listening for WireGuard connections
    firewall_add_port external "${WG_SERVICE_PORT}/udp"
fi
