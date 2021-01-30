#!/usr/bin/env bash

for user in "${UNPRIVILEGED_USERS[@]}"
do
    test -d "/home/${user}" || create_user "${user}"
done
