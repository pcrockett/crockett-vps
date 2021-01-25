#!/usr/bin/env bash

# TODO: Build a Dendrite image and run it.
#
#     https://github.com/matrix-org/dendrite/tree/master/build/docker
#
# Either we can do something manual, potentially involving this command...
#
#    podman build --tag dendrite SOME_DOCKERFILE
#
# ... or perhaps https://github.com/containers/podman-compose will work well
# enough for us.

image_name="docker.io/matrixdotorg/dendrite-monolith:latest"
container_name="dendrite"

run_unprivileged podman container exists "${container_name}" \
    || run_unprivileged podman container create \
        --name "${container_name}" \
        --publish 8008:8008 \
        --publish 8448:8448 \
        --volume "dendrite-data:/etc/dendrite" \
        "${image_name}"
