#!/usr/bin/env bash

function install_podman() {
    yes | pacman --sync crun podman
}

is_installed podman || install_podman
