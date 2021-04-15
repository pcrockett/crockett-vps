#!/usr/bin/env bash

readonly CHECKPOINT_NGINX_RELOAD="nginx-reload"

function nginx_reload_when_finished() {
    unset_checkpoint "${CHECKPOINT_NGINX_RELOAD}" # Make sure we reload nginx at end of script
}

function nginx_reload_is_required() {
    is_unset_checkpoint "${CHECKPOINT_NGINX_RELOAD}"
}

function nginx_reloaded() {
    set_checkpoint "${CHECKPOINT_NGINX_RELOAD}"
}

is_installed nginx || install_package nginx
is_installed certbot || install_package certbot

if is_unset_checkpoint "${CHECKPOINT_NGINX_CONF}"; then
    place_template "etc/nginx/nginx.conf"
    nginx_reload_when_finished
    set_checkpoint "${CHECKPOINT_NGINX_CONF}"
fi

enable_and_start nginx

function need_tls_cert() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Domain name"
    test ! -f "/etc/letsencrypt/live/${1}/privkey.pem"
}

function get_tls_cert() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Domain name"
    certbot certonly --webroot \
        --webroot-path /usr/share/nginx/html \
        --domain "${1}" \
        --email "${LETSENCRYPT_ADMIN_EMAIL}" \
        --rsa-key-size 4096 \
        --agree-tos \
        --no-eff-email
}

if need_tls_cert "${DOMAIN_MATRIX}"; then
    get_tls_cert "${DOMAIN_MATRIX}"
    nginx_reload_when_finished
fi

if need_tls_cert "${DOMAIN_ELEMENT}"; then
    get_tls_cert "${DOMAIN_ELEMENT}"
    nginx_reload_when_finished
fi

if need_tls_cert "${DOMAIN_MATRIX_IDENTITY}"; then
    get_tls_cert "${DOMAIN_MATRIX_IDENTITY}"
    nginx_reload_when_finished
fi

if need_tls_cert "${DOMAIN_PRIMARY}"; then
    get_tls_cert "${DOMAIN_PRIMARY}"
    nginx_reload_when_finished
fi

if need_tls_cert "${DOMAIN_HUGINN}"; then
    get_tls_cert "${DOMAIN_HUGINN}"
    nginx_reload_when_finished
fi

letsencrypt_ssl_options="/etc/letsencrypt/options-ssl-nginx.conf"
if [ ! -f "${letsencrypt_ssl_options}" ]; then
    ssl_options_url="https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf"
    curl "${ssl_options_url}" > "${letsencrypt_ssl_options}"
    nginx_reload_when_finished
fi

if is_unset_checkpoint "nginx-firewall-settings"; then

    firewall_add_service external http
    firewall_add_service external https
    firewall_add_port external 8448/tcp # Matrix federation only necessary on external
    firewall_add_service vpn http
    firewall_add_service vpn https

    set_checkpoint "nginx-firewall-settings"
fi

if nginx_reload_is_required; then
    place_template "etc/nginx/nginx.conf"
    place_file "etc/nginx/acme-challenge.conf"
    place_file "usr/share/nginx/html/.well-known/acme-challenge/.placeholder"
    nginx -s reload
    nginx_reloaded
fi

install_and_start_timer certbot
