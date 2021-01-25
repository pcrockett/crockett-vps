#!/usr/bin/env bash

if [ -f "${WARNING_FILE}" ]; then
    echo "Warnings generated:"
    sort "${WARNING_FILE}" | uniq
    rm "${WARNING_FILE}"
fi

if is_unset_checkpoint "initial-run-finished"; then
    echo "Done with initial setup."
    set_checkpoint "initial-run-finished"
fi
