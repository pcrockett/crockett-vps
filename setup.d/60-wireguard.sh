#!/usr/bin/env bash

is_installed wg-quick || install_package wireguard-tools

if value_not_exists "wg-public-key"; then

    # We haven't set up WireGuard yet.

    private_key=$(wg genkey)
    public_key=$(echo "${private_key}" | wg pubkey)
    WG_PRIVATE_KEY="${private_key}" place_template "etc/wireguard/wg0.conf"
    enable_and_start "wg-quick@wg0"

    set_value "wg-private-key" "${private_key}"
    set_value "wg-public-key" "${public_key}"
fi
