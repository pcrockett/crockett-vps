#!/usr/bin/env bash

function install_nginx() {
    yes | pacman --sync nginx
}

is_installed nginx || install_nginx

if is_unset_checkpoint "nginx-conf"; then
    place_template "etc/nginx/nginx.conf"
    set_checkpoint "nginx-conf"
fi

systemctl is-active nginx || systemctl start nginx > /dev/null 2>&1
systemctl is-enabled nginx || systemctl enable nginx > /dev/null 2>&1

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
fi

nginx -s reload
