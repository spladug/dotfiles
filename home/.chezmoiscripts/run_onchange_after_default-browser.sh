#!/bin/sh
# Chromium (via the chromium.desktop override) is the browser everywhere. GNOME
# keeps this in ~/.config/mimeapps.list, which it also rewrites on its own, so it
# is set here rather than by managing that file.
#
# xdg-mime, NOT `xdg-settings set default-web-browser`: xdg-settings also edits
# ~/.local/share/applications/chromium.desktop, appending a MimeType line at the
# end of the file -- inside the [Desktop Action new-private-window] group, where
# it is meaningless -- and drops it from [Desktop Entry]. That breaks the
# chezmoi-managed override.
command -v xdg-mime >/dev/null 2>&1 || exit 0
exec xdg-mime default chromium.desktop \
    x-scheme-handler/http x-scheme-handler/https text/html application/xhtml+xml
