#!/usr/bin/env bash

test -d "/home/${UNPRIVILEGED_USER}" || create_user "${UNPRIVILEGED_USER}"
