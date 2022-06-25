#!/usr/bin/env bash

image_name="docker.io/huginn/huginn:latest"
container_name="huginn"
container_data_dir="/var/lib/mysql"
volume_name="huginn-data"
volume="${volume_name}:${container_data_dir}"

function container_initial_setup() {
    true # Don't need to do anything for this step
}
export initial_setup

function container_refresh_config() {

    install_service huginn

    if container_exists; then
        stop_service huginn
    fi
}

function container_update() {

    if container_exists; then
        run_as_container_user podman pull "${image_name}"
        stop_service huginn
        run_as_container_user podman container rm "${container_name}"
    fi
}
export container_update

function container_start() {

    if container_exists; then
        enable_and_start huginn
    else
        run_as_container_user \
            podman container create \
            --name "${container_name}" \
            --publish 3000:3000 \
            --volume "${volume}" \
            --env "SMTP_USER_NAME=${SMTP_USER}" \
            --env "SMTP_PASSWORD=${SMTP_PASSWORD}" \
            --env "SMTP_SERVER=${SMTP_SERVER}" \
            --env "EMAIL_FROM_ADDRESS=${HUGINN_EMAIL_FROM}" \
            --env "DOMAIN=${DOMAIN_HUGINN}" \
            --env REQUIRE_CONFIRMED_EMAIL=true \
            --env RAILS_ENV=production \
            --env INVITATION_CODE="$(random_secret 64)" \
            --env APP_SECRET_TOKEN="$(random_secret 64)" \
            "${image_name}" > /dev/null

        enable_and_start huginn
    fi
}
export container_start
