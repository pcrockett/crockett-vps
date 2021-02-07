#!/usr/bin/env bash

set -Eeuo pipefail

[[ "${BASH_VERSINFO[0]}" -lt 5 ]] && echo "Bash >= 5 required" && exit 1

readonly REPO_ROOT=$(dirname "$(readlink -f "${0}")")
"${REPO_ROOT}/admin-tools/server-cmd.sh" "${@}"
