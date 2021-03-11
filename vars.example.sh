#!/usr/bin/env bash

###############################################################################
# Network config                                                              #
###############################################################################

readonly NET_PRIMARY_INTERFACE="eth0"
export NET_PRIMARY_INTERFACE

###############################################################################
# SSH config                                                                  #
###############################################################################

readonly SSH_SERVICE_PORT=27980
export SSH_SERVICE_PORT

readonly ROOT_SSH_KEY="PASTE YOUR ADMIN DEVICE'S SSH PUBLIC KEY HERE"
export ROOT_SSH_KEY

readonly UNPRIVILEGED_SSH_KEY="${ROOT_SSH_KEY}"
export UNPRIVILEGED_SSH_KEY

###############################################################################
# Admin info                                                                  #
###############################################################################

# The email address where you want to receive general server admin
# notifications, such as for pending semi-automatic updates.
readonly GENERAL_ADMIN_EMAIL="admin@philcrockett.com"
export GENERAL_ADMIN_EMAIL

# The email address you want associated with your Let's Encrypt TLS
# certificates. Let's Encrypt will email you expiration warnings here.
readonly LETSENCRYPT_ADMIN_EMAIL="${GENERAL_ADMIN_EMAIL}"
export LETSENCRYPT_ADMIN_EMAIL

readonly MATRIX_ADMIN_USER="admin" # Will be created as the first Matrix user account
export MATRIX_ADMIN_USER

###############################################################################
# Domain config                                                               #
###############################################################################

readonly DOMAIN_PRIMARY="crockett.network"
export DOMAIN_PRIMARY

readonly DOMAIN_MATRIX="matrix.${DOMAIN_PRIMARY}"
export DOMAIN_MATRIX

readonly DOMAIN_MATRIX_IDENTITY="identity.${DOMAIN_MATRIX}"
export DOMAIN_MATRIX_IDENTITY

readonly MATRIX_SERVER_NAME="${DOMAIN_PRIMARY}"
export MATRIX_SERVER_NAME

readonly DOMAIN_ELEMENT="chat.${DOMAIN_PRIMARY}"
export DOMAIN_ELEMENT

readonly DOMAIN_JITSI="meet.jit.si" # Maybe some day we can host our own Jitsi server, but let's use a free public one for now
export DOMAIN_JITSI

readonly DOMAIN_SOCIAL_LOCAL="social.${DOMAIN_PRIMARY}"
export DOMAIN_SOCIAL_LOCAL

readonly DOMAIN_TURN="turn.${DOMAIN_PRIMARY}"
export DOMAIN_TURN

###############################################################################
# SMTP config                                                                 #
###############################################################################

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

# Synapse will email users with this "from" address
readonly MATRIX_EMAIL_FROM="matrix@${DOMAIN_PRIMARY}"
export MATRIX_EMAIL_FROM

# General server notifications will email the administrator (you) with this
# "from" address
readonly ADMIN_EMAIL_FROM="root@${DOMAIN_PRIMARY}"
export ADMIN_EMAIL_FROM

readonly HUGINN_EMAIL_FROM="huginn@${DOMAIN_PRIMARY}"
export HUGINN_EMAIL_FROM

###############################################################################
# TURN config                                                                 #
###############################################################################

readonly TURN_MIN_PORT=49160
export TURN_MIN_PORT

readonly TURN_MAX_PORT=49200
export TURN_MAX_PORT

###############################################################################
# WireGuard config                                                            #
###############################################################################

readonly WG_SERVICE_PORT=40719
export WG_SERVICE_PORT

readonly WG_NETWORK_PART="10.17.32" # First 3 octets for WireGuard VPN network
export WG_NETWORK_PART

###############################################################################
# Health check config                                                         #
###############################################################################

# My preferred monitoring service is https://healthchecks.io, but others like
# https://cronitor.io will work as well
readonly HEALTHCHECK_AUTOUPDATE_URL="https://hc-ping.com/SOME_ID"
export HEALTHCHECK_AUTOUPDATE_URL

readonly HEALTHCHECK_AUTOUPDATE_START_URL="${HEALTHCHECK_AUTOUPDATE_URL}/start"
export HEALTHCHECK_AUTOUPDATE_START_URL
