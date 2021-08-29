#!/usr/bin/env bash

function tailscale_up() {
    tailscale up --advertise-exit-node --accept-dns=false
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

    # These enable IP forwarding temporarily until reboot
    sysctl --write net.ipv4.ip_forward=1 > /dev/null
    sysctl --write net.ipv6.conf.all.forwarding=1 > /dev/null
    sysctl --write net.ipv6.conf.default.forwarding=1 > /dev/null

    # This is how we enable IP forwarding permanently
    place_file "etc/sysctl.d/30-ipforward.conf"

    tailscale_up
fi
