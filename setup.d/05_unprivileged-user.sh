#!/usr/bin/env bash

test ! -d "/home/${UNPRIVILEGED_USER}" || return 0

echo "Creating user ${UNPRIVILEGED_USER}..."

if is_root; then
    useradd --create-home --shell /usr/bin/bash "${UNPRIVILEGED_USER}"
    passwd "${UNPRIVILEGED_USER}"
    groupadd --system "${UNPRIVILEGED_USER}"
    gpasswd --add "${UNPRIVILEGED_USER}" "${UNPRIVILEGED_USER}"
else
    sudo --preserve-env "$(readlink -f "${0}")"
fi
