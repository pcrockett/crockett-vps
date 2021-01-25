#!/usr/bin/env bash

test -f "${WARNING_FILE}" || return 0

echo "Warnings generated:"
uniq "${WARNING_FILE}"
rm "${WARNING_FILE}"
