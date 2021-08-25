#!/usr/bin/env bash

function tailscale_up() {
    tailscale up --advertise-exit-node
}

if is_installed tailscale; then
    if tailscale status > /dev/null; then
        true # Nothing to do, we're already connected
    else
        tailscale_up
    fi
else
    install_package tailscale
    enable_and_start tailscaled
    tailscale_up

    sysctl --write net.ipv4.ip_forward=1 > /dev/null

    # Enable masquerading (NAT) from tailscale to the external interface
    # Stole much of this from https://firewalld.org/2020/09/policy-objects-filtering-container-and-vm-traffic
    # Now that I'm switching to tailscale, this may not be necessary
    #
    # run_firewall_cmd --new-policy vpn-nat
    # run_firewall_cmd --policy vpn-nat --add-ingress-zone vpn
    # run_firewall_cmd --policy vpn-nat --add-egress-zone external
    # run_firewall_cmd --policy vpn-nat --add-masquerade

    # Actually apply the vpn zone to our new tailscale interface
    run_firewall_cmd --zone vpn --change-interface tailscale0
fi
