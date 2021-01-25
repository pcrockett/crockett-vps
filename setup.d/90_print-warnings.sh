#!/usr/bin/env bash

test -f "${WARNING_FILE}" || return 0

echo "Warnings generated:"
sort "${WARNING_FILE}" | uniq
rm "${WARNING_FILE}"
