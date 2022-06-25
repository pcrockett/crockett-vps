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
ip6tables --flush

# Allow localhost processes to talk
iptables --append INPUT --in-interface lo --jump ACCEPT
ip6tables --append INPUT --in-interface lo --jump ACCEPT

# Allow remote machines to respond to us when we talk to them
iptables --append INPUT --match conntrack --ctstate RELATED,ESTABLISHED --jump ACCEPT
ip6tables --append INPUT --match conntrack --ctstate RELATED,ESTABLISHED --jump ACCEPT

# SSH
iptables --append INPUT --protocol tcp --dport "${SSH_SERVICE_PORT}" --jump ACCEPT

# Web
iptables --append INPUT --protocol tcp --dport 80 --jump ACCEPT
iptables --append INPUT --protocol tcp --dport 443 --jump ACCEPT

# This makes Tailscale direct connections possible: https://tailscale.com/kb/1082/firewall-ports/
iptables --append INPUT --protocol udp --dport 41641 --jump ACCEPT

iptables --policy INPUT DROP
ip6tables --policy INPUT DROP
iptables --policy FORWARD DROP
ip6tables --policy FORWARD DROP

iptables-save -f /etc/iptables/iptables.rules
ip6tables-save -f /etc/iptables/ip6tables.rules

enable_and_start iptables
enable_and_start ip6tables

set_checkpoint "firewall-config"
