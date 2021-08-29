#!/usr/bin/env bash

is_unset_checkpoint "firewall-config" || return 0

###
#
# You may notice we don't configure NAT or VPN rules here. That's because
# Tailscale handles that stuff for us.
#
###

# Start fresh
iptables --flush

# Allow localhost processes to talk
iptables --append INPUT --in-interface lo --jump ACCEPT

# Allow remote machines to respond to us when we talk to them
iptables --append INPUT --match conntrack --ctstate RELATED,ESTABLISHED --jump ACCEPT

# SSH
iptables --append INPUT --protocol tcp --dport "${SSH_SERVICE_PORT}" --jump ACCEPT

# Web
iptables --append INPUT --protocol tcp --dport 80 --jump ACCEPT
iptables --append INPUT --protocol tcp --dport 443 --jump ACCEPT

# Matrix federation
iptables --append INPUT --protocol tcp --dport 8448 --jump ACCEPT

# TURN
iptables --append INPUT --protocol tcp --dport 3478 --jump ACCEPT

_turn_port_count=$((TURN_MAX_PORT-TURN_MIN_PORT))
iptables --append INPUT --protocol udp --dport "${TURN_MIN_PORT}:${_turn_port_count}" --jump ACCEPT

# This makes Tailscale direct connections possible: https://tailscale.com/kb/1082/firewall-ports/
iptables --append INPUT --protocol udp --dport 41641 --jump ACCEPT

iptables-save -f /etc/iptables/iptables.rules

enable_and_start iptables

set_checkpoint "firewall-config"
