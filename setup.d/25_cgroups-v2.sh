#!/usr/bin/env bash

test ! -f /sys/fs/cgroup/cgroup.controllers || return 0

# If the cgroup.controllers file doesn't exit, then we're using cgroups v1. Let's change that.
if is_unset_checkpoint "v2-cgroups-enabled"; then
    new_cmdline="$(cat /proc/cmdline) systemd.unified_cgroup_heirarchy=1"
    echo "${new_cmdline}" > /proc/cmdline
    set_checkpoint "v2-cgroups-enabled"
fi

read -r -p "v2 cgroups enabled, but a reboot is required. Reboot now? (y/N): " decision

if [ "${decision}" == "y" ] || [ "${decision}" == "Y" ]; then
    systemctl reboot
    return 0
else
    return 1
fi
