#!/usr/bin/env bash

source_dir="$REPO_ROOT/admin-tools"
bin_dir="/usr/local/bin"

function put_admin_tool() {
    ln --symbolic "${source_dir}/${1}.sh" "${bin_dir}/${1}"
}

is_installed new-matrix-user || put_admin_tool new-matrix-user
is_installed new-wireguard-peer || put_admin_tool new-wireguard-peer
is_installed checknews || put_admin_tool checknews
is_installed server-cmd || put_admin_tool server-cmd
