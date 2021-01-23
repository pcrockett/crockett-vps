#!/usr/bin/env bash

function install_nginx() {
    yes | pacman --sync nginx
}

is_installed nginx || install_nginx

test_checkpoint "nginx-conf" || place_file "etc/nginx/nginx.conf"
set_checkpoint "nginx-conf"

systemctl status nginx || systemctl start nginx
systemctl enable nginx
