#!/usr/bin/env sh
qtile cmd-obj -o cmd -f restart
pkill conky
conky -c ~/.conkyrc &
pkill polybar
launch_polybar.sh
pkill nm-applet
#pkill redshift-gtk
nm-applet &
#redshift-gtk &
change_wallpaper
