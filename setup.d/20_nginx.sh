#!/usr/bin/env bash

function install_nginx() {
    yes | pacman --sync nginx
}

is_installed nginx || install_nginx

if is_unset_checkpoint "nginx-conf"; then
    place_template "etc/nginx/nginx.conf"
    set_checkpoint "nginx-conf"
    unset_checkpoint "nginx-reload" # Make sure we reload nginx at end of script
fi

systemctl is-active nginx > /dev/null || systemctl start nginx > /dev/null
systemctl is-enabled nginx > /dev/null || systemctl enable nginx > /dev/null

function install_certbot() {
    yes | pacman --sync certbot certbot-nginx
}

is_installed certbot || install_certbot

if [ ! -f "/etc/letsencrypt/live/${DOMAIN_PRIMARY}/privkey.pem" ]; then
    certbot --nginx \
        --domain "${DOMAIN_PRIMARY}" \
        --email "${ADMIN_EMAIL}" \
        --rsa-key-size 4096 \
        --agree-tos \
        --no-eff-email

    unset_checkpoint "nginx-reload" # Make sure we reload nginx at end of script
fi

if is_unset_checkpoint "nginx-reload"; then
    nginx -s reload > /dev/null
    set_checkpoint "nginx-reload"
fi
