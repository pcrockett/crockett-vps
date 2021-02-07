#!/usr/bin/env bash

image_name="docker.io/matrixdotorg/sydent-build:latest"
container_name="sydent"

function run_as_sydent() {
    run_unprivileged sydent "${@}"
}

function container_exists() {
    run_as_sydent podman container exists "${container_name}"
}

install_service sydent

if container_exists; then
    enable_and_start sydent
else

    run_as_sydent podman container create \
        --name "${container_name}" \
        --publish 8090:8090 \
        --volume "sydent-data:/data" \
        "${image_name}" > /dev/null

    enable_and_start sydent
fi
