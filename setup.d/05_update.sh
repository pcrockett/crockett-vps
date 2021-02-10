#!/usr/bin/env bash

# TODO: We might want to create some more scripts based on https://wiki.archlinux.org/index.php/System_maintenance

is_unset_checkpoint "${CHECKPOINT_SYSUPGRADE}" || return 0

readonly CHECKPOINT_INITIAL_UPGRADE="initial-upgrade"

checknews_script="${ADMIN_TOOLS_DIR}/checknews.sh"

if is_unset_checkpoint "${CHECKPOINT_INITIAL_UPGRADE}"; then

    # This is the first run. We can assume that there won't be any issues
    # updating packages on a clean install. Right? Mark all news up to this
    # date "read" so that we only print warnings for new articles.
    "${checknews_script}" --mark-read

else

    # The user is wanting to update a server that's already configured. Let's
    # make sure there aren't any new news articles she needs to be concerned
    # about.

    if "${checknews_script}"; then
        # News article has been published recently. The user has already been directed to the news page.
        echo "If you still want to continue, run \`checknews --mark-read\` and then try again."
        exit 1
    fi

fi

exec_pacman --sync --refresh --sysupgrade

set_checkpoint "${CHECKPOINT_SYSUPGRADE}"

is_unset_checkpoint "${CHECKPOINT_INITIAL_UPGRADE}" || return 0
set_checkpoint "${CHECKPOINT_INITIAL_UPGRADE}"

read -r -p "Initial upgrade finished. Reboot now? (y/N): " decision

if [ "${decision}" == "y" ] || [ "${decision}" == "Y" ]; then
    systemctl reboot
    return 0
fi
