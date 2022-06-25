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

###############################################################################
# Domain config                                                               #
###############################################################################

readonly DOMAIN_PRIMARY="crockett.network"
export DOMAIN_PRIMARY

readonly DOMAIN_JITSI="meet.jit.si" # Maybe some day we can host our own Jitsi server, but let's use a free public one for now
export DOMAIN_JITSI

readonly DOMAIN_SOCIAL_LOCAL="social.${DOMAIN_PRIMARY}"
export DOMAIN_SOCIAL_LOCAL

readonly DOMAIN_HUGINN="huginn.${DOMAIN_PRIMARY}"
export DOMAIN_HUGINN

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

# General server notifications will email the administrator (you) with this
# "from" address
readonly ADMIN_EMAIL_FROM="root@${DOMAIN_PRIMARY}"
export ADMIN_EMAIL_FROM

readonly HUGINN_EMAIL_FROM="huginn@${DOMAIN_PRIMARY}"
export HUGINN_EMAIL_FROM

###############################################################################
# Health check config                                                         #
###############################################################################

# My preferred monitoring service is https://healthchecks.io, but others like
# https://cronitor.io will work as well
readonly HEALTHCHECK_AUTOUPDATE_URL="https://hc-ping.com/SOME_ID"
export HEALTHCHECK_AUTOUPDATE_URL

readonly HEALTHCHECK_AUTOUPDATE_START_URL="${HEALTHCHECK_AUTOUPDATE_URL}/start"
export HEALTHCHECK_AUTOUPDATE_START_URL

readonly HEALTHCHECK_CERTBOT_RENEW_URL="https://hc-ping.com/SOME_ID"
export HEALTHCHECK_CERTBOT_RENEW_URL
