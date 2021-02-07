#!/usr/bin/env bash

# TODO: We might want to create some more scripts based on https://wiki.archlinux.org/index.php/System_maintenance

is_unset_checkpoint "${CHECKPOINT_SYSUPGRADE}" || return 0
exec_pacman --sync --refresh --sysupgrade
set_checkpoint "${CHECKPOINT_SYSUPGRADE}"

is_unset_checkpoint "initial-upgrade" || return 0
set_checkpoint "initial-upgrade"

read -r -p "Initial upgrade finished. Reboot now? (y/N): " decision

if [ "${decision}" == "y" ] || [ "${decision}" == "Y" ]; then
    systemctl reboot
    return 0
fi
