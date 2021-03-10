#!/usr/bin/env bash

image_name="docker.io/matrixdotorg/synapse:latest"
container_name="synapse"
container_data_dir="/data"
volume_name="synapse-data"
volume="${volume_name}:${container_data_dir}"

function container_initial_setup() {

    run_as_container_user \
        podman container run \
        --volume "${volume}" \
        --env SYNAPSE_SERVER_NAME="${DOMAIN_MATRIX}" \
        --env SYNAPSE_REPORT_STATS=no \
        "${image_name}" generate

}
export initial_setup

function container_refresh_config() {

    place_template "home/synapse/homeserver.yaml"
    place_template "usr/share/nginx/html/.well-known/matrix/server"
    install_service synapse

    if container_exists; then
        stop_service synapse
    fi

    is_installed jq || install_package jq
    volume_raw_data="$(run_as_container_user podman volume inspect "${volume_name}")"
    host_volume_dir="$(echo "${volume_raw_data}" | jq -r .[0].Mountpoint)"

    mv /home/synapse/homeserver.yaml "${host_volume_dir}"
    chown "synapse:synapse" "${host_volume_dir}/homeserver.yaml"
}

function container_update() {

    if container_exists; then
        run_as_container_user podman pull "${image_name}"
        stop_service synapse
        run_as_container_user podman container rm "${container_name}"
    fi
}
export container_update

function container_start() {

    if container_exists; then
        enable_and_start synapse
    else
        run_as_container_user podman container create \
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
}
export container_start
