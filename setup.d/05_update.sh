#!/usr/bin/env bash

# TODO: We might want to create some more scripts based on https://wiki.archlinux.org/index.php/System_maintenance

is_unset_checkpoint "initial-upgrade" || return 0

function do_update() {

    # pacman has some weird exit codes. However we know two things:
    #
    # * pacman returns 0 or any number of other exit codes for "success"
    # * pacman returns 1 for "error"
    #

    if yes | pacman --sync --refresh --sysupgrade; then
        true
    else
        test "${?}" -ne 1
    fi
}

do_update

set_checkpoint "initial-upgrade"

read -r -p "Initial upgrade finished. Reboot now? (y/N): " decision

if [ "${decision}" == "y" ] || [ "${decision}" == "Y" ]; then
    systemctl reboot
    return 0
fi
