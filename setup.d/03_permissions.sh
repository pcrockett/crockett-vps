#!/usr/bin/env bash

is_unset_checkpoint "repo-permissions" || return 0

# Only root should be able to read stuff in this directory. Especially the .values directory.
chmod --recursive go-rwx "${REPO_ROOT}"

set_checkpoint "repo-permissions"
