#!/usr/bin/env bash

image_name="docker.io/matrixdotorg/synapse:latest"
container_name="synapse"
container_data_dir="/data"
volume_name="synapse-data"
volume="${volume_name}:${container_data_dir}"

function run_as_synapse() {
    run_unprivileged synapse "${@}"
}

if is_unset_checkpoint "synapse-generate"; then

    run_as_synapse \
        podman container run \
        --volume "${volume}" \
        --env SYNAPSE_SERVER_NAME="${DOMAIN_MATRIX}" \
        --env SYNAPSE_REPORT_STATS=no \
        "${image_name}" generate

    set_checkpoint "synapse-generate"
fi

is_installed jq || install_package jq
volume_raw_data=$(run_as_synapse podman volume inspect "${volume_name}")
host_volume_dir=$(echo "${volume_raw_data}" | jq -r .[0].Mountpoint)

if is_unset_checkpoint "${CHECKPOINT_MATRIX_CONF}"; then
    place_template "tmp/homeserver.yaml"

    if run_as_synapse podman container exists "${container_name}"; then
        run_as_synapse podman container stop "${container_name}" > /dev/null
    fi

    mv /tmp/homeserver.yaml "${host_volume_dir}"
    chown "synapse:synapse" "${host_volume_dir}/homeserver.yaml"

    set_checkpoint "${CHECKPOINT_MATRIX_CONF}"
fi

if run_as_synapse podman container exists "${container_name}"; then
    run_as_synapse podman container start "${container_name}" > /dev/null
else

    # Now create the actual container where Dendrite will run
    run_as_synapse podman container create \
        --name "${container_name}" \
        --publish 8008:8008 \
        --volume "${volume}" \
        "${image_name}" > /dev/null

    run_as_synapse podman container start "${container_name}" > /dev/null
fi

place_template "usr/share/nginx/html/.well-known/matrix/server"
