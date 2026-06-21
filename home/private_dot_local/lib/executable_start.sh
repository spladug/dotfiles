#!/bin/sh

wmctrl -s 0
firefox &
chromium --disable-session-crashed-bubble &
1password &
sleep 5

wmctrl -s 8
obsidian &
cider &
sleep 2

wmctrl -s 9
slack &
discord &
signal-desktop &
