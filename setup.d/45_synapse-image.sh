#!/usr/bin/env bash

image_name="docker.io/matrixdotorg/synapse:latest"
container_name="synapse"
container_data_dir="/data"
volume_name="synapse-data"
volume="${volume_name}:${container_data_dir}"

if is_unset_checkpoint "synapse-generate"; then

    run_unprivileged podman container run \
        --volume "${volume}" \
        --env SYNAPSE_SERVER_NAME="${MATRIX_SERVER_NAME}" \
        --env SYNAPSE_REPORT_STATS=no \
        "${image_name}" generate

    set_checkpoint "synapse-generate"
fi

is_installed jq || install_package jq
volume_raw_data=$(run_unprivileged podman volume inspect "${volume_name}")
host_volume_dir=$(echo "${volume_raw_data}" | jq -r .[0].Mountpoint)

if is_unset_checkpoint "${CHECKPOINT_MATRIX_CONF}"; then
    place_template "tmp/homeserver.yaml"

    if run_unprivileged podman container exists "${container_name}"; then
        run_unprivileged podman container stop "${container_name}"
    fi

    mv /tmp/homeserver.yaml "${host_volume_dir}"
    chown "${UNPRIVILEGED_USER}:${UNPRIVILEGED_USER}" "${host_volume_dir}/homeserver.yaml"

    set_checkpoint "${CHECKPOINT_MATRIX_CONF}"
fi

if run_unprivileged podman container exists "${container_name}"; then
    run_unprivileged podman container start "${container_name}" > /dev/null
else

    # Now create the actual container where Dendrite will run
    run_unprivileged podman container create \
        --name "${container_name}" \
        --publish 8008:8008 \
        --volume "${volume}" \
        "${image_name}"

    run_unprivileged podman container start "${container_name}" > /dev/null
fi

place_template "usr/share/nginx/html/.well-known/matrix/server"
