#!/usr/bin/env bash

function install_nginx() {
    yes | pacman --sync nginx
}

is_installed nginx || install_nginx

test_checkpoint "nginx-conf" || place_file "etc/nginx/nginx.conf"
set_checkpoint "nginx-conf"

systemctl is-active nginx || systemctl start nginx > /dev/null 2>&1
systemctl is-enabled nginx || systemctl enable nginx > /dev/null 2>&1

function install_certbot() {
    yes | pacman --sync certbot certbot-nginx
}

is_installed certbot || install_certbot

# TODO: Check if we need this first
certbot --nginx \
    --domain "${DOMAIN_PRIMARY}" \
    --email "${ADMIN_EMAIL}" \
    --rsa-key-size 4096 \
    --agree-tos \
    --hsts
