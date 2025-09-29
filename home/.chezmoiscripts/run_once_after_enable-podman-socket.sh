#!/bin/sh

exec systemctl --user enable --now podman.socket
