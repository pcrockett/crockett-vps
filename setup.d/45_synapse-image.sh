#!/usr/bin/env bash

image_name="docker.io/matrixdotorg/synapse:latest"
container_name="synapse"
container_data_dir="/data"
volume_name="synapse-data"
volume="${volume_name}:${container_data_dir}"

function run_as_synapse() {
    run_unprivileged synapse "${@}"
}

function container_exists() {
    run_as_synapse podman container exists "${container_name}"
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
    place_template "home/synapse/homeserver.yaml"
    place_template "usr/share/nginx/html/.well-known/matrix/server"

    if container_exists; then
        stop_service synapse
    fi

    mv /home/synapse/homeserver.yaml "${host_volume_dir}"
    chown "synapse:synapse" "${host_volume_dir}/homeserver.yaml"

    set_checkpoint "${CHECKPOINT_MATRIX_CONF}"
fi

install_service synapse

if is_unset_checkpoint "${CHECKPOINT_CONTAINER_UPDATE}" && container_exists; then

    run_as_synapse podman pull "${image_name}"
    stop_service synapse
    run_as_synapse podman container rm "${container_name}" # We will re-create it below

    # Intentionally not setting the "update" checkpoint. That happens at the end of the whole process.
fi

if container_exists; then
    enable_and_start synapse
else

    run_as_synapse podman container create \
        --name "${container_name}" \
        --publish 8008:8008 \
        --volume "${volume}" \
        "${image_name}" > /dev/null

    enable_and_start synapse
fi

if is_unset_checkpoint "matrix-admin-user"; then

    echo "Creating Matrix admin user..."
    "${REPO_ROOT}/admin-tools/new-matrix-user.sh" --username "${MATRIX_ADMIN_USER}" --admin
    set_checkpoint "matrix-admin-user"
fi
