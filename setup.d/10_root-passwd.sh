#!/usr/bin/env bash

is_unset_checkpoint "root-passwd" || return 0
echo "Setting root password..."
passwd
set_checkpoint "root-passwd"
