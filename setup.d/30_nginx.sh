#!/usr/bin/env bash

is_installed nginx || install_package nginx
is_installed certbot || install_package certbot certbot-nginx

if is_unset_checkpoint "${CHECKPOINT_NGINX_CONF}"; then
    place_template "etc/nginx/nginx.conf"
    unset_checkpoint "nginx-reload" # Make sure we reload nginx at end of script
    set_checkpoint "${CHECKPOINT_NGINX_CONF}"
fi

systemctl is-active nginx > /dev/null || systemctl start nginx > /dev/null
systemctl is-enabled nginx > /dev/null || systemctl enable nginx > /dev/null

if [ ! -f "/etc/letsencrypt/live/${DOMAIN_PRIMARY}/privkey.pem" ]; then
    certbot --nginx \
        --domain "${DOMAIN_PRIMARY}" \
        --email "${ADMIN_EMAIL}" \
        --rsa-key-size 4096 \
        --agree-tos \
        --no-eff-email

    place_template "etc/nginx/nginx.conf" # Re-generate the nginx config with Certbot settings
    unset_checkpoint "nginx-reload" # Make sure we reload nginx at end of script
fi

if is_unset_checkpoint "nginx-reload"; then
    nginx -s reload
    set_checkpoint "nginx-reload"
fi
