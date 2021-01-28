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

readonly DOMAIN_ELEMENT="im.crockett.network"
export DOMAIN_ELEMENT

readonly DOMAIN_JITSI="meet.crockett.network"
export DOMAIN_JITSI

readonly SMTP_SERVER="smtp.fastmail.com"
export SMTP_SERVER

readonly SMTP_PORT="587"
export SMTP_PORT

readonly SMTP_USER="YOUR USERNAME HERE"
export SMTP_USER

readonly SMTP_PASSWORD="YOUR PASSWORD HERE"
export SMTP_PASSWORD

readonly SMTP_TLS="true"
export SMTP_TLS

readonly SMTP_FROM_ADDRESS="matrix@crockett.network"
export SMTP_FROM_ADDRESS
