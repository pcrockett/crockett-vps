#!/usr/bin/env bash

cat << EOF
{
    "default_server_config": {
        "m.homeserver": {
            "base_url": "https://${DOMAIN_MATRIX}",
            "server_name": "${MATRIX_SERVER_NAME}"
        },
        "m.identity_server": {
            "base_url": "https://vector.im"
        }
    },
    "disable_custom_urls": true,
    "disable_guests": false,
    "disable_login_language_selector": false,
    "disable_3pid_login": false,
    "brand": "Element",
    "integrations_ui_url": "https://scalar.vector.im/",
    "integrations_rest_url": "https://scalar.vector.im/api",
    "integrations_widgets_urls": [
        "https://scalar.vector.im/_matrix/integrations/v1",
        "https://scalar.vector.im/api",
        "https://scalar-staging.vector.im/_matrix/integrations/v1",
        "https://scalar-staging.vector.im/api",
        "https://scalar-staging.riot.im/scalar/api"
    ],
    "bug_report_endpoint_url": "https://element.io/bugreports/submit",
    "defaultCountryCode": "US",
    "showLabsSettings": false,
    "features": {
        "feature_new_spinner": false
    },
    "default_federate": true,
    "default_theme": "light",
    "roomDirectory": {
        "servers": [
            "${DOMAIN_MATRIX}"
        ]
    },
    "enable_presence_by_hs_url": {
        "https://matrix.org": false,
        "https://matrix-client.matrix.org": false
    },
    "settingDefaults": {
        "breadcrumbs": true
    },
    "jitsi": {
        "preferredDomain": "${DOMAIN_JITSI}"
    }
}

EOF
