#!/usr/bin/env bash

image_name="docker.io/vectorim/element-web:latest"
container_name="element"
container_config_file="/app/config.json" # The path where Element data is stored INSIDE the container
host_config_file="/home/${UNPRIVILEGED_USER}/element.json"

if [ ! -f "${host_config_file}" ]; then
    place_template "tmp/element.json"
    mv /tmp/element.json "${host_config_file}"
    chown "${UNPRIVILEGED_USER}:${UNPRIVILEGED_USER}" "${host_config_file}"
fi

if run_unprivileged podman container exists "${container_name}"; then
    run_unprivileged podman container start "${container_name}" > /dev/null
else

    # Now create the actual container where Dendrite will run
    run_unprivileged podman container create \
        --name "${container_name}" \
        --publish 8080:80 \
        --volume "${host_config_file}:${container_config_file}" \
        "${image_name}" > /dev/null

    run_unprivileged podman container start "${container_name}" > /dev/null
fi
