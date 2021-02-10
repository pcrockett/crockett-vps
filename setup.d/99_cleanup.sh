#!/usr/bin/env bash

if is_unset_checkpoint "${CHECKPOINT_FIREWALL_RELOAD}"; then
    firewall-cmd --reload
    set_checkpoint "${CHECKPOINT_FIREWALL_RELOAD}"
fi

if is_unset_checkpoint "initial-run-finished"; then
    echo "Done with initial setup."
    set_checkpoint "initial-run-finished"
fi

# Prevent containers from being updated on EVERY invocation of server-cmd
set_checkpoint "${CHECKPOINT_CONTAINER_UPDATE}"

if is_unset_checkpoint "${CHECKPOINT_PACDIFF}"; then
    pacdiff_list="$(pacdiff --output)"
    file_count="$(printf "%s" "${pacdiff_list}" | wc --lines)"
    if [ "${file_count}" -eq 0 ]; then
        set_checkpoint "${CHECKPOINT_PACDIFF}"
    else
        printf "pacman generated some files that you should probably review:\n\n%s\n" "${pacdiff_list}"
        exit 1
    fi
fi
