#!/usr/bin/env bash

readonly UNPRIVILEGED_USER="podman"
export UNPRIVILEGED_USER

readonly ROOT_SSH_KEY="PASTE YOUR ADMIN DEVICE'S SSH PUBLIC KEY HERE"
export ROOT_SSH_KEY

readonly UNPRIVILEGED_SSH_KEY="${ROOT_SSH_KEY}"
export UNPRIVILEGED_SSH_KEY

readonly ADMIN_EMAIL="admin@philcrockett.com"
export ADMIN_EMAIL

readonly DOMAIN_PRIMARY="de.crockett.network"
export DOMAIN_PRIMARY

readonly DOMAIN_MATRIX="matrix.crockett.network"
export DOMAIN_MATRIX

readonly MATRIX_SERVER_NAME="${DOMAIN_MATRIX}"
export MATRIX_SERVER_NAME

# Restrict Matrix account creation to those who know a special shared secret
readonly MATRIX_REGISTRATION_SHARED_SECRET=""
export MATRIX_REGISTRATION_SHARED_SECRET

readonly DOMAIN_ELEMENT="im.crockett.network"
export DOMAIN_ELEMENT

readonly DOMAIN_JITSI="meet.crockett.network"
export DOMAIN_JITSI
