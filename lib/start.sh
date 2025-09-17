#!/bin/sh

wmctrl -s 0
firefox &
mullvad-exclude chromium --disable-session-crashed-bubble &
1password &
sleep 5

wmctrl -s 8
obsidian &
cider &
sleep 2

wmctrl -s 9
mullvad-exclude slack &
discord &
signal-desktop &
