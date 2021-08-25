#!/usr/bin/env bash

is_unset_checkpoint "firewall-config" || return 0

is_installed firewall-cmd || install_package firewalld
enable_and_start firewalld

# Network topology:
#
# * Our Internet-facing interface will be in the "external" zone (which comes
#   pre-configured with firewalld)
# * Our Tailscale interface will be in the "vpn" zone (which we will create)
#

run_firewall_cmd --new-zone vpn # We will apply this zone to the Tailscale interface later

# Apply zones to interfaces
run_firewall_cmd --zone external --change-interface "${NET_PRIMARY_INTERFACE}"

firewall-cmd --reload

set_checkpoint "firewall-config"
