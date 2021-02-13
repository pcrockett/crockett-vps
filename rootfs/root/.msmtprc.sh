#!/usr/bin/env bash

if [ "${SMTP_TLS}" == "true" ]; then
    msmtp_tls=on
else
    msmtp_tls=off
fi

cat << EOF
account adminmail
host ${SMTP_SERVER}
port ${SMTP_PORT}
auth on
tls ${msmtp_tls}
password ${SMTP_PASSWORD}
user ${SMTP_USER}
from ${ADMIN_EMAIL_FROM}

# Set a default account
account default : adminmail

EOF
