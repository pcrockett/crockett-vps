#!/usr/bin/env bash

for user in "${UNPRIVILEGED_USERS[@]}"
do
    test -d "/home/${user}" || create_user "${user}"

    # Start a user manager service for this user at boot. Podman needs this.
    loginctl enable-linger "${user}"
done
