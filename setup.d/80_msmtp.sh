#!/usr/bin/env bash

is_installed msmtp || install_package msmtp

config_file="root/.msmtprc"
if [ ! -f "/${config_file}" ]; then
    place_template "${config_file}"
    chmod go-rwx "/${config_file}"
fi
