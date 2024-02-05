#!/bin/sh

set -e

light_url="file://$(find ~/Pictures/Wallpapers/Light -type f | shuf -n 1)"
dark_url="file://$(find ~/Pictures/Wallpapers/Dark -type f | shuf -n 1)"

gsettings set org.gnome.desktop.background picture-uri "$light_url"
gsettings set org.gnome.desktop.background picture-uri-dark "$dark_url"
gsettings set org.gnome.desktop.screensaver picture-uri "$dark_url"
