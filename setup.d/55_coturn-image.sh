#!/usr/bin/env bash

image_name="docker.io/instrumentisto/coturn:latest"
container_name="coturn"
turn_port=3478

value_exists "external-ip" || set_value "external-ip" "$(curl -4 https://icanhazip.com/)"
external_ip="$(get_value "external-ip")"

value_exists "${VAL_TURN_SECRET}" || set_value "${VAL_TURN_SECRET}" "$(random_secret 64)"
turn_secret=$(get_value "${VAL_TURN_SECRET}")

function run_as_turn() {
    run_unprivileged turn "${@}"
}

if run_as_turn podman container exists "${container_name}"; then
    run_as_turn podman container start "${container_name}" > /dev/null
else

    # Much guidance from:
    #
    # * https://github.com/matrix-org/synapse/blob/develop/docs/turn-howto.md
    # * https://github.com/instrumentisto/coturn-docker-image
    # * https://github.com/coturn/coturn/blob/master/README.turnserver
    #

    run_as_turn podman container create \
        --name "${container_name}" \
        --publish "${turn_port}:${turn_port}" \
        --publish "${TURN_MIN_PORT}-${TURN_MAX_PORT}:${TURN_MIN_PORT}-${TURN_MAX_PORT}/udp" \
        "${image_name}" \
        -n \
        "--realm=${DOMAIN_TURN}" \
        --log-file=stdout \
        "--external-ip=${external_ip}" \
        "--min-port=${TURN_MIN_PORT}" \
        "--max-port=${TURN_MAX_PORT}" \
        --use-auth-secret \
        "--static-auth-secret=${turn_secret}" \
        --no-tcp-relay \
        --denied-peer-ip=10.0.0.0-10.255.255.255 \
        --denied-peer-ip=192.168.0.0-192.168.255.255 \
        --denied-peer-ip=172.16.0.0-172.31.255.255 \
        --user-quota=12 \
        --total-quota=1200 \
        > /dev/null

    # TODO: Add support for TLS?

    run_as_turn podman container start "${container_name}" > /dev/null
fi

if is_unset_checkpoint "turn-firewall-settings"; then

    firewall_add_port external "${turn_port}/tcp"
    firewall_add_port external "${TURN_MIN_PORT}-${TURN_MAX_PORT}/udp"
    firewall_add_port vpn "${turn_port}/tcp"
    firewall_add_port vpn "${TURN_MIN_PORT}-${TURN_MAX_PORT}/udp"

    set_checkpoint "turn-firewall-settings"
fi
