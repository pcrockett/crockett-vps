#!/usr/bin/env bash

is_unset_checkpoint "dns-settings" || return 0

place_file "etc/systemd/resolved.conf"
systemctl restart systemd-resolved

set_checkpoint "dns-settings"
