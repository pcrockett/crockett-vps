#!/usr/bin/env bash

is_installed nginx || install_package nginx
is_installed certbot || install_package certbot

if is_unset_checkpoint "${CHECKPOINT_NGINX_CONF}"; then
    place_template "etc/nginx/nginx.conf"
    unset_checkpoint "nginx-reload" # Make sure we reload nginx at end of script
    set_checkpoint "${CHECKPOINT_NGINX_CONF}"
fi

systemctl is-active nginx > /dev/null || systemctl start nginx > /dev/null
systemctl is-enabled nginx > /dev/null || systemctl enable nginx > /dev/null

function need_tls_cert() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Domain name"
    test ! -f "/etc/letsencrypt/live/${1}/privkey.pem"
}

function get_tls_cert() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Domain name"
    certbot certonly --webroot \
        --webroot-path /usr/share/nginx/html \
        --domain "${1}" \
        --email "${ADMIN_EMAIL}" \
        --rsa-key-size 4096 \
        --agree-tos \
        --no-eff-email
}

if need_tls_cert "${DOMAIN_PRIMARY}"; then
    get_tls_cert "${DOMAIN_PRIMARY}"
    unset_checkpoint "nginx-reload" # Make sure we reload nginx at end of script
fi

if need_tls_cert "${DOMAIN_MATRIX}"; then
    get_tls_cert "${DOMAIN_MATRIX}"
    unset_checkpoint "nginx-reload" # Make sure we reload nginx at end of script
fi

if need_tls_cert "${DOMAIN_ELEMENT}"; then
    get_tls_cert "${DOMAIN_ELEMENT}"
    unset_checkpoint "nginx-reload" # Make sure we reload nginx at end of script
fi

if need_tls_cert "${DOMAIN_SOCIAL_PUBLIC}"; then
    get_tls_cert "${DOMAIN_SOCIAL_PUBLIC}"
    unset_checkpoint "nginx-reload" # Make sure we reload nginx at end of script
fi

if is_unset_checkpoint "nginx-reload"; then
    place_template "etc/nginx/nginx.conf" # Re-generate the nginx config now that we know Certbot is in place.
    nginx -s reload
    set_checkpoint "nginx-reload"
fi
