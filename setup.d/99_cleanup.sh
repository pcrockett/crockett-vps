#!/usr/bin/env bash

if [ -f "${WARNING_FILE}" ]; then
    echo "Warnings generated:"
    sort "${WARNING_FILE}" | uniq
    rm "${WARNING_FILE}"
fi

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
