from subprocess import Popen, PIPE
import re
import os

LOCALBIN = "~/Local/bin"

CHANGE_WALLPAPER = os.path.expanduser(f"{LOCALBIN}/change_wallpaper")
# POLYBAR = "polybar g57"
POLYBAR = os.path.expanduser(f"{LOCALBIN}/launch_polybar.sh")
UDISKIE = "udiskie"
NM_APPLET = "nm-applet"
DUNST = "dunst"
BROWSER = ""

AUTOSTART_LIST = [DUNST, NM_APPLET, UDISKIE]

TERMINAL = "alacritty"

BRIGHTNESSCTL = "brightnessctl"
XRANDR = "xrandr"
BRIGHTNESS_ICON = "/usr/share/icons/Arc/status/symbolic/brightness-display-symbolic.svg"


def brightness_get():
    return 100


def brightness_modify(operation):
    return 100
