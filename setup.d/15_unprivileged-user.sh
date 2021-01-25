#!/usr/bin/env bash

test ! -d "/home/${UNPRIVILEGED_USER}" || return 0

echo "Creating user ${UNPRIVILEGED_USER}..."
useradd --create-home --shell /usr/bin/bash "${UNPRIVILEGED_USER}"
passwd "${UNPRIVILEGED_USER}"
