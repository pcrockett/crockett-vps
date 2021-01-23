#!/usr/bin/env bash

test_checkpoint "root-passwd" || return 0
echo "Setting root password..."
passwd
set_checkpoint "root-passwd"
