#!/usr/bin/env bash

# We don't need to run this script if v2 cgroups are already enabled.
test ! -f /sys/fs/cgroup/unified/cgroup.controllers || return 0

# If the cgroup.controllers file doesn't exit, then we're using cgroups v1. Let's change that.
if is_unset_checkpoint "v2-cgroups-enabled"; then

    grub_config_file="/etc/default/grub"

    current_cmdline="$(grep "^GRUB_CMDLINE_LINUX_DEFAULT=\".*\"\$" "${grub_config_file}")"

    # ${current_cmdline} probably looks something like this:
    #
    #     GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"
    #

    # shellcheck disable=SC2001
    new_cmdline="$(echo "${current_cmdline}" | sed "s/\"$/ systemd.unified_cgroup_heirarchy=1\"/")"
    # Disabled SC2001 because we need more advanced functionality of sed (finding the last `"` character)

    # ${new_cmdline} probably looks something like this:
    #
    #     GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 systemd.unified_cgroup_heirarchy=1"
    #

    # Now simply replace the current cmdline with the new cmdline
    sed --in-place "s/${current_cmdline}/${new_cmdline}/" "${grub_config_file}"

    # Rebuild Grub boot config
    grub-mkconfig --output /boot/grub/grub.cfg

    set_checkpoint "v2-cgroups-enabled"
fi

read -r -p "v2 cgroups enabled, but a reboot is required. Reboot now? (y/N): " decision

if [ "${decision}" == "y" ] || [ "${decision}" == "Y" ]; then
    systemctl reboot
    return 0
else
    return 1
fi
