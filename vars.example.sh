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
# Domain config                                                               #
###############################################################################

readonly LETSENCRYPT_ADMIN_EMAIL="admin@philcrockett.com"
export LETSENCRYPT_ADMIN_EMAIL

readonly DOMAIN_PRIMARY="crockett.network"
export DOMAIN_PRIMARY

readonly DOMAIN_MATRIX="matrix.${DOMAIN_PRIMARY}"
export DOMAIN_MATRIX

readonly MATRIX_SERVER_NAME="${DOMAIN_PRIMARY}"
export MATRIX_SERVER_NAME

readonly DOMAIN_ELEMENT="chat.${DOMAIN_PRIMARY}"
export DOMAIN_ELEMENT

readonly DOMAIN_JITSI="meet.jit.si"
export DOMAIN_JITSI

readonly DOMAIN_SOCIAL_LOCAL="social.${DOMAIN_PRIMARY}"
export DOMAIN_SOCIAL_LOCAL

readonly DOMAIN_TURN="turn.${DOMAIN_PRIMARY}"
export DOMAIN_TURN

###############################################################################
# Matrix SMTP config                                                          #
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

readonly SMTP_FROM_ADDRESS="matrix@${DOMAIN_PRIMARY}"
export SMTP_FROM_ADDRESS

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
