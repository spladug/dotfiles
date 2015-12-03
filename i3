set $mod Mod1
set $font DejaVu Sans Mono
set $font_size 9
set $gray "#1e2426"
set $purple "#632d85"


###### appearance
font pango:$font $font_size
new_window normal 1
# class                     border      bg          text        indicator
client.focused              $purple     $purple     #ffffff     $purple
client.focused_inactive     #311642     #311642     #666666     #311642

# register this session with gdm so we don't time out
exec --no-startup-id dbus-send --session --print-reply=literal --dest=org.gnome.SessionManager "/org/gnome/SessionManager" org.gnome.SessionManager.RegisterClient "string:i3" "string:$DESKTOP_AUTOSTART_ID"
# set a nice gray background
exec --no-startup-id xsetroot -solid '#333333'
# calming red tones for night owls
exec --no-startup-id redshift-gtk

##### window customization
for_window [class="Dwb"] border none
for_window [class="Firefox" window_role="browser"] border none
for_window [class="google-chrome" window_role="browser"] border none
for_window [class="Gnome-terminal"] border 1pixel
for_window [title="GVIM$"] border 1pixel
for_window [window_role="pop-up"] floating enable
for_window [window_role="task_dialog"] floating enable
for_window [title="Preferences$"] floating enable
for_window [title="Chromium$"] border none
for_window [title="Enter Passphrase"] floating enable
for_window [class="update-manager"] floating enable

###### key bindings
# Use Mouse+$mod to drag floating windows to their wanted position
floating_modifier $mod

# start a terminal
bindsym $mod+Shift+Return exec i3-sensible-terminal

# kill focused window
bindsym $mod+Shift+q kill

# start dmenu (a program launcher)
bindsym $mod+p exec dmenu_run -i -b -fn "$font-$font_size" -nb "$gray" -nf '#babdb6' -sb "$purple" -sf '#ffffff' -p 'run> '
bindsym $mod+Shift+p exec passmenu --type -i -b -fn "$font-$font_size" -nb "$gray" -nf '#babdb6' -sb "$purple" -sf '#ffffff' -p 'password> '

# change focus
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# move focused window
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# split in horizontal/vertical orientation
bindsym $mod+v split v
bindsym $mod+Shift+v split h

# enter fullscreen mode for the focused container
bindsym $mod+f fullscreen

# change container layout (stacked, tabbed, toggle split)
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

# toggle tiling / floating
bindsym $mod+Shift+space floating toggle

# change focus between tiling / floating windows
bindsym $mod+space focus mode_toggle

# focus the parent container
bindsym $mod+a focus parent

# focus the child container
#bindsym $mod+d focus child

# switch to workspace
bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
bindsym $mod+3 workspace number 3
bindsym $mod+4 workspace number 4
bindsym $mod+5 workspace number 5
bindsym $mod+6 workspace number 6
bindsym $mod+7 workspace number 7
bindsym $mod+8 workspace number 8
bindsym $mod+9 workspace number 9
bindsym $mod+0 workspace number 10

# allow renaming workspace
bindsym $mod+t exec i3-input -F 'rename workspace to "%s"' -P 'New name for this workspace: '

# move focused container to workspace
bindsym $mod+Shift+1 move container to workspace number 1
bindsym $mod+Shift+2 move container to workspace number 2
bindsym $mod+Shift+3 move container to workspace number 3
bindsym $mod+Shift+4 move container to workspace number 4
bindsym $mod+Shift+5 move container to workspace number 5
bindsym $mod+Shift+6 move container to workspace number 6
bindsym $mod+Shift+7 move container to workspace number 7
bindsym $mod+Shift+8 move container to workspace number 8
bindsym $mod+Shift+9 move container to workspace number 9
bindsym $mod+Shift+0 move container to workspace number 10

bindsym $mod+Right workspace next
bindsym $mod+Left workspace prev

# reload the configuration file
bindsym $mod+Shift+c reload
# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym $mod+Shift+r restart
# exit i3 (logs you out of your X session)
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'gnome-session-quit --force'"

# resize window (you can also use the mouse for that)
mode "resize" {
        # These bindings trigger as soon as you enter the resize mode

        # Pressing left will shrink the window’s width.
        # Pressing right will grow the window’s width.
        # Pressing up will shrink the window’s height.
        # Pressing down will grow the window’s height.
        bindsym h resize shrink width 10 px or 10 ppt
        bindsym j resize grow height 10 px or 10 ppt
        bindsym k resize shrink height 10 px or 10 ppt
        bindsym l resize grow width 10 px or 10 ppt

        # back to normal: Enter or Escape
        bindsym Return mode "default"
        bindsym Escape mode "default"
}

bindsym $mod+r mode "resize"


####### control audio volume without gnome
bindsym XF86AudioRaiseVolume exec pactl set-sink-volume 0 +5%
bindsym XF86AudioLowerVolume exec pactl set-sink-volume 0 -- -5%
bindsym XF86AudioMute exec pactl set-sink-mute 0 toggle
bindsym XF86AudioMicMute exec pactl set-source-mute 1 toggle


###### move workspaces among screens
bindsym $mod+b move workspace to output HDMI1
bindsym $mod+n move workspace to output LVDS1


###### status bar
bar {
        status_command i3status
        font pango: $font $font_size
        position top
        colors {
            separator #ffffff

        }
}
