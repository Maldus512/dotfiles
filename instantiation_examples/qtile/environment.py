from subprocess import Popen, PIPE
import re
import os
import brightness_impl
import volume_impl

LOCALBIN = "~/Local/bin"

CHANGE_WALLPAPER = os.path.expanduser(f"{LOCALBIN}/change_wallpaper")
# POLYBAR = "polybar g57"
POLYBAR = os.path.expanduser(f"{LOCALBIN}/launch_polybar.sh")
UDISKIE = "udiskie"
CONKY = f"conky -c {os.path.expanduser('~/.conkyrc')}"
NM_APPLET = "nm-applet"
DUNST = "dunst"
REDSHIFT = "redshift-gtk"
POLKIT = "lxsession"
BROWSER = "flatpak run org.mozilla.firefox"
KEYRING = "gnome-keyring-daemon --daemonize"
REST = os.path.expanduser(f"~/Local/bin/101010.lua")

AUTOSTART_LIST = [CHANGE_WALLPAPER.split(), UDISKIE.split(), NM_APPLET.split(), CONKY.split(), POLYBAR.split(), DUNST.split(), KEYRING.split(), REST.split()]

# TERMINAL = "wezterm"
TERMINAL = "kitty"

ICONS_PATH = os.path.expanduser("~/Local/share/icons/qtile")


# Brightness configuration

BRIGHTNESS_ICON = ""
brightness_get = brightness_impl.brightness_get_xrandr
brightness_modify = brightness_impl.brightness_modify_xrandr

volume_show = volume_impl.amixer_show
volume_modify = volume_impl.amixer_modify
volume_toggle = volume_impl.amixer_toggle
