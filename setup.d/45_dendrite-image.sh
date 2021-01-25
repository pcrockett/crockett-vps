#!/usr/bin/env bash

# TODO: Build a Dendrite image and run it.
#
#     https://github.com/matrix-org/dendrite/tree/master/build/docker
#
# The following is a work in progress.

image_name="docker.io/matrixdotorg/dendrite-monolith:latest"
container_name="dendrite"
container_data_dir="/etc/dendrite" # The path where Dendrite data is stored inside the container
volume_name="dendrite-data"
volume="${volume_name}:${container_data_dir}"

if is_unset_checkpoint "dendrite-keys"; then
    # First run. Generate keys and save them in the dendrite-data volume.
    run_unprivileged podman container run \
        --entrypoint /usr/bin/generate-keys \
        --volume "${volume}" \
        "${image_name}" \
        "--private-key=${container_data_dir}/matrix_key.pem" \
        "--tls-cert=${container_data_dir}/server.crt" \
        "--tls-key=${container_data_dir}/server.key"

    set_checkpoint "dendrite-keys"
fi

is_installed jq || install_package jq
volume_raw_data=$(run_unprivileged podman volume inspect "${volume_name}")
host_volume_dir=$(echo "${volume_raw_data}" | jq -r .[0].Mountpoint)

if [ ! -f "${host_volume_dir}/dendrite.yaml" ]; then
    place_template "tmp/dendrite.yaml"
    mv /tmp/dendrite.yaml "${host_volume_dir}"
    chown "${UNPRIVILEGED_USER}:${UNPRIVILEGED_USER}" "${host_volume_dir}/dendrite.yaml"
fi

if run_unprivileged podman container exists "${container_name}"; then
    run_unprivileged podman container start "${container_name}"
else

    # Now create the actual container where Dendrite will run
    run_unprivileged podman container create \
        --name "${container_name}" \
        --publish 8008:8008 \
        --publish 8448:8448 \
        --volume "${volume}" \
        "${image_name}"

    run_unprivileged podman container start "${container_name}"
fi
