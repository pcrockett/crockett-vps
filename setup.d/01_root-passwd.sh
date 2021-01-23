#!/usr/bin/env bash

echo "Setting root password..."

if is_root; then
    passwd
else
    sudo passwd
fi
