#!/bin/sh

wmctrl -s 0
firefox &
mullvad-exclude chromium &
1password &
sleep 10

wmctrl -s 8
obsidian &
sleep 5

wmctrl -s 9
mullvad-exclude slack &
discord &
signal-desktop &
