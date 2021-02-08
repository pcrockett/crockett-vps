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

if is_unset_checkpoint "${CHECKPOINT_CONTAINER_UPDATE}" && container_exists; then

    run_as_sydent podman pull "${image_name}"
    stop_service sydent
    run_as_sydent podman container rm "${container_name}" # We will re-create it below

    # Intentionally not setting the "update" checkpoint. That happens at the end of the whole process.
fi

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
