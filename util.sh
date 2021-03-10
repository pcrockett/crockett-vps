#!/usr/bin/env bash

set -Eeuo pipefail

[[ "${BASH_VERSINFO[0]}" -lt 5 ]] && echo "Bash >= 5 required" && exit 1

readonly CHECKPOINT_NGINX_CONF="nginx-conf"
export CHECKPOINT_NGINX_CONF

readonly CHECKPOINT_MATRIX_CONF="container-synapse-config-refresh"
export CHECKPOINT_MATRIX_CONF

readonly CHECKPOINT_ELEMENT_CONF="element-conf"
export CHECKPOINT_ELEMENT_CONF

readonly CHECKPOINT_FIREWALL_RELOAD="firewall-reload"
export CHECKPOINT_FIREWALL_RELOAD

readonly CHECKPOINT_SYSUPGRADE="sysupgrade"
export CHECKPOINT_SYSUPGRADE

readonly CHECKPOINT_CONTAINER_UPDATE="container-update"
export CHECKPOINT_CONTAINER_UPDATE

readonly CHECKPOINT_PACDIFF="pacdiff"
export CHECKPOINT_PACDIFF

readonly VAL_TURN_SECRET="turn-secret"
export VAL_TURN_SECRET

readonly CHECKPOINTS_DIR="${REPO_ROOT}/.checkpoints"
test -d "${CHECKPOINTS_DIR}" || mkdir "${CHECKPOINTS_DIR}" > /dev/null

readonly VALUES_DIR="${REPO_ROOT}/.values"
test -d "${VALUES_DIR}" || mkdir "${VALUES_DIR}" > /dev/null

readonly UNPRIVILEGED_USERS=(
    synapse
    element
    turn
    sydent
)
export UNPRIVILEGED_USERS

function panic() {
    >&2 echo "Fatal: ${*}"
    exit 1
}
export panic

function is_installed() {
    command -v "${1}" >/dev/null 2>&1
}
export is_installed

function exec_pacman() {

    # Run pacman, recording all stderr to a file. Then dump that file into
    # warnings for the user to review when finished.

    local result=0
    if echo "y" | pacman "${@}"; then
        result=0 # All good
    else
        if [ "${?}" -eq 1 ]; then
            result=1 # There was an error
        else
            result=0 # There was a non-zero exit code, but it wasn't an error
        fi
    fi

    if [ "${result}" -eq 0 ]; then
        unset_checkpoint "${CHECKPOINT_PACDIFF}"
    fi

    return "${result}"
}
export exec_pacman

function install_package() {

    test "${#}" -ge 1 || panic "Expecting at least 1 argument: Package name(s)"

    # pacman has some weird exit codes. However we know two things:
    #
    # * pacman returns 0 or any number of other exit codes for "success"
    # * pacman returns 1 for "error"
    #

    exec_pacman --sync --refresh --sysupgrade "${@}"
}
export install_package

function is_set() {
    # Use this like so:
    #
    #     is_set "${VAR_NAME+x}" || show_usage_and_exit
    #
    # https://stackoverflow.com/a/13864829

    test ! -z "${1}"
}
export is_set

function is_root() {
    test "$(id -u)" -eq 0
}
export is_root

function is_unset_checkpoint() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Checkpoint name"
    test ! -f "${CHECKPOINTS_DIR}/${1}"
}
export is_unset_checkpoint

function is_checkpoint_set() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Checkpoint name"
    test -f "${CHECKPOINTS_DIR}/${1}"
}
export is_checkpoint_set

function set_checkpoint() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Checkpoint name"
    touch "${CHECKPOINTS_DIR}/${1}"
}
export set_checkpoint

function unset_checkpoint() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Checkpoint name"
    checkpoint_path="${CHECKPOINTS_DIR}/${1}"
    if [ -f "${checkpoint_path}" ]; then
        rm "${checkpoint_path}"
    fi
}
export unset_checkpoint

function value_exists() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Value key"
    local value_path="${VALUES_DIR}/${1}"
    test -f "${value_path}"
}
export value_exists

function value_not_exists() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Value key"
    if value_exists "${1}"; then
        false
    else
        true
    fi
}
export value_not_exists

function get_value() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Value key"
    local value_path="${VALUES_DIR}/${1}"
    test -f "${value_path}" || panic "Value \"${1}\" has not been set yet."
    cat "${value_path}"
}
export get_value

function set_value() {
    test "${#}" -eq 2 || panic "Expecting 2 arguments: Key and value"
    local value_path="${VALUES_DIR}/${1}"
    echo "${2}" > "${value_path}"
}
export set_value

function place_file() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: File path"

    src_path="${REPO_ROOT}/rootfs/${1}"
    dest_path="/${1}"

    if [ -f "${dest_path}" ]; then
        old_path="${dest_path}.old"
        mv "${dest_path}" "${old_path}"
    fi

    parent_dir=$(dirname "${dest_path}")
    test -d "${parent_dir}" || mkdir --parent "${parent_dir}" > /dev/null

    cp "${src_path}" "${dest_path}"
}
export place_file

function place_template() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Template path"

    template_src="${REPO_ROOT}/rootfs/${1}.sh"
    test -x "${template_src}" || panic "${template_src} is not executable."

    dest_path="/${1}"
    if [ -f "${dest_path}" ]; then
        old_path="${dest_path}.old"
        mv "${dest_path}" "${old_path}"
    fi

    parent_dir=$(dirname "${dest_path}")
    test -d "${parent_dir}" || mkdir --parent "${parent_dir}" > /dev/null

    # shellcheck source=/dev/null
    . "${template_src}" > "${dest_path}"
}
export place_template

function run_unprivileged() {
    test "${#}" -ge 2 || panic "Expecting at least 2 arguments: Username and command to run"

    local user="${1}"
    shift 1

    sudo --login --user "${user}" "${@}"
}
export run_unprivileged

function random_secret() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Number of bytes of randomness"
    openssl rand -hex "${1}"
}
export random_secret

function create_user() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Username"
    local username="${1}"
    useradd --create-home --shell /usr/bin/bash "${username}"

    # It doesn't matter what the password is for the user; we'll never use it.
    # Just set it to something strong.
    local password;
    password="$(random_secret 32)"
    echo "${username}:${password}" | chpasswd
}
export create_user

function enable_and_start() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Service name"
    local service_name="${1}"
    systemctl is-active "${service_name}" > /dev/null \
        || systemctl start "${service_name}" > /dev/null
    systemctl is-enabled "${service_name}" > /dev/null \
        || systemctl enable "${service_name}" > /dev/null
}
export enable_and_start

function install_service() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Service name"
    service_file="etc/systemd/system/${1}.service"
    if [ ! -f "/${service_file}" ]; then
        place_file "${service_file}"
        systemctl daemon-reload
    fi
}
export install_service

function stop_service() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Service name"
    local service_name="${1}"
    if systemctl is-active "${service_name}" > /dev/null; then
        systemctl stop "${service_name}" > /dev/null
    fi
}
export stop_service

function install_and_start_timer() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Timer name"
    timer_file="etc/systemd/system/${1}.timer"
    service_file="etc/systemd/system/${1}.service"
    if [ ! -f "/${timer_file}" ]; then
        place_file "${service_file}"
        place_file "${timer_file}"
        systemctl daemon-reload
        systemctl enable "${1}.timer"
        systemctl start "${1}.timer"
    fi
}
export install_and_start_timer

function run_firewall_cmd() {
    is_installed firewall-cmd || panic "firewalld not installed yet."
    firewall-cmd --permanent "${@}" > /dev/null
    unset_checkpoint "${CHECKPOINT_FIREWALL_RELOAD}"
}
export run_firewall_cmd

function firewall_add_port() {
    test "${#}" -eq 2 || panic "Expecting 2 arguments: Zone and port specification."
    run_firewall_cmd --zone "${1}" --add-port "${2}"
    unset_checkpoint "${CHECKPOINT_FIREWALL_RELOAD}"
}
export firewall_add_port

function firewall_add_service() {
    test "${#}" -eq 2 || panic "Expecting 2 arguments: Zone and service name."
    run_firewall_cmd --zone "${1}" --add-service "${2}"
    unset_checkpoint "${CHECKPOINT_FIREWALL_RELOAD}"
}
export firewall_add_service

function send_admin_email() {
    # Example usage:
    #
    # echo "This is the body of the email" | send_admin_email "Test Subject"
    #

    local email_body
    email_body="$(cat)"
    test "${#}" -eq 1 || panic "Expecting 1 argument: Email subject."

    printf "Subject: [%s] %s\n%s" "${DOMAIN_PRIMARY}" "${1}" "${email_body}" \
        | msmtp --account default "${GENERAL_ADMIN_EMAIL}"
}
export send_admin_email

function configure_container() {
    test "${#}" -eq 1 || panic "Expecting 1 argument: Container name"

    local container_name="${1}"
    local container_script="${REPO_ROOT}/containers/${container_name}.sh"

    (
        function run_as_container_user() {
            # Container name should be same as user name
            run_unprivileged "${container_name}" "${@}"
        }

        function container_exists() {
            run_as_container_user podman container exists "${container_name}"
        }

        # shellcheck source=/dev/null
        source "${container_script}"

        if is_unset_checkpoint "container-${container_name}-init"; then
            container_initial_setup
            set_checkpoint "container-${container_name}-init"
        fi

        if is_unset_checkpoint "container-${container_name}-config-refresh"; then
            container_refresh_config
            set_checkpoint "container-${container_name}-config-refresh"
        fi

        if is_unset_checkpoint "${CHECKPOINT_CONTAINER_UPDATE}"; then
            container_update
        fi

        container_start
    )
}
export configure_container
