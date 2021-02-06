#!/usr/bin/env bash

image_name="docker.io/matrixdotorg/sydent-build:latest"
container_name="sydent"

function run_as_sydent() {
    run_unprivileged sydent "${@}"
}

function container_exists() {
    run_as_sydent podman container exists "${container_name}"
}

function start_container() {
    run_as_sydent podman container start "${container_name}" > /dev/null
}

function stop_container() {
    run_as_sydent podman container stop "${container_name}" > /dev/null
}

if container_exists; then
    start_container
else

    run_as_sydent podman container create \
        --name "${container_name}" \
        --publish 8090:8090 \
        --volume "sydent-data:/data" \
        "${image_name}" > /dev/null

    start_container
fi
