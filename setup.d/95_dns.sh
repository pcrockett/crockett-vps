#!/usr/bin/env bash

is_unset_checkpoint "dns-settings" || return 0

place_file "etc/systemd/resolved.conf"
systemctl restart systemd-resolved

# We would be fine with just systemd-resolved, however we want to provide DNS
# to the peers who join our WireGuard VPN. That's not what systemd-resolved is
# for. Install dnsmasq for that task.
is_installed dnsmasq || install_package dnsmasq
enable_and_start dnsmasq

firewall_add_service vpn dns # We only want to run a DNS server for our WireGuard peers

set_checkpoint "dns-settings"
