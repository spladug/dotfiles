#!/bin/sh

if ! command -v podman >/dev/null 2>&1; then
    echo "podman not yet installed"
    exit 0
fi

exec systemctl --user enable --now podman.socket
