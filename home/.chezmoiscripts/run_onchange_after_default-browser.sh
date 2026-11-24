#!/bin/sh
# Chromium (via the chromium.desktop override) is the browser everywhere. GNOME
# keeps this in ~/.config/mimeapps.list, which it also rewrites on its own, so it
# is set here rather than by managing that file.
command -v xdg-settings >/dev/null 2>&1 || exit 0
exec xdg-settings set default-web-browser chromium.desktop
