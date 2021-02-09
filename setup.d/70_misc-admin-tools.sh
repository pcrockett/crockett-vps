#!/usr/bin/env bash

# pacdiff and checkupdates are useful tools from pacman-contrib
is_installed pacdiff || install_package pacman-contrib

# yq to parse the Arch news feed before auto updates
is_installed yq || install_package yq
