#!/usr/bin/env bash

test_checkpoint "root-passwd" || return 0

echo "Setting root password..."

if is_root; then
    passwd
else
    sudo passwd
fi

set_checkpoint "root-passwd"
