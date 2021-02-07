#!/usr/bin/env bash

image_name="docker.io/vectorim/element-web:latest"
container_name="element"
container_config_file="/app/config.json" # The path where Element data is stored INSIDE the container
host_config_file="home/element/element.json" # Intentionally leaving out the first slash

function run_as_element() {
    run_unprivileged element "${@}"
}

function container_exists() {
    run_as_element podman container exists "${container_name}"
}

if is_unset_checkpoint "${CHECKPOINT_ELEMENT_CONF}"; then
    # Element may already be running, but the user may be trying to change configuration
    if container_exists; then
        systemctl stop element
        rm "/${host_config_file}"
    fi
fi

if [ ! -f "/${host_config_file}" ]; then
    place_template "${host_config_file}"
    chown element:element "/${host_config_file}"
fi

set_checkpoint "${CHECKPOINT_ELEMENT_CONF}"

install_service element

if container_exists; then
    enable_and_start element
else

    run_as_element podman container create \
        --name "${container_name}" \
        --publish 8080:80 \
        --volume "/${host_config_file}:${container_config_file}" \
        "${image_name}" > /dev/null

    enable_and_start element
fi
