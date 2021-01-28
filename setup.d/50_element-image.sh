#!/usr/bin/env bash

image_name="docker.io/vectorim/element-web:latest"
container_name="element"
container_data_dir="/app" # The path where Element data is stored INSIDE the container
volume_name="element-data"
volume="${volume_name}:${container_data_dir}"

if is_unset_checkpoint "element-volume"; then
    run_unprivileged podman volume create "${volume_name}"
    set_checkpoint "element-volume"
fi

volume_raw_data=$(run_unprivileged podman volume inspect "${volume_name}")
host_volume_dir=$(echo "${volume_raw_data}" | jq -r .[0].Mountpoint)

if [ ! -f "${host_volume_dir}/element.json" ]; then
    place_template "tmp/element.json"
    mv /tmp/element.json "${host_volume_dir}/config.json"
    chown "${UNPRIVILEGED_USER}:${UNPRIVILEGED_USER}" "${host_volume_dir}/config.json"
fi

if run_unprivileged podman container exists "${container_name}"; then
    run_unprivileged podman container start "${container_name}" > /dev/null
else

    # Now create the actual container where Dendrite will run
    run_unprivileged podman container create \
        --name "${container_name}" \
        --publish 8080:80 \
        --volume "${volume}" \
        "${image_name}"

    run_unprivileged podman container start "${container_name}" > /dev/null
fi
