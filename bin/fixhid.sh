
xinput set-button-map "USB Optical Mouse" 3 2 1 4 5 6 7 
xinput set-button-map "Microsoft  Microsoft Basic Optical Mouse v2.0" 3 2 1 4 5 6 7 

xinput set-prop "DualPoint Stick" "Evdev Wheel Emulation Button" 2
xinput set-prop "DualPoint Stick" "Evdev Wheel Emulation" 1
xinput set-prop "DualPoint Stick" "Evdev Wheel Emulation Axes" 6 7 4 5

xinput set-prop 'Apple Magic Mouse' 'Device Accel Velocity Scaling' 1


if xrandr | grep "HDMI1 connected"
then
    xrandr --output HDMI1 --primary --auto --above LVDS1 --output LVDS1 --auto
else
    xrandr --output VGA1 --primary --auto --above LVDS1 --output LVDS1 --auto
fi

xset b off
xset b 0 0 0

