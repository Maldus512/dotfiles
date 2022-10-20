import os

LOCALBIN = "~/Local/bin"

CHANGE_WALLPAPER = os.path.expanduser(f"{LOCALBIN}/change_wallpaper")
#POLYBAR = "polybar g57"
POLYBAR = os.path.expanduser(f"{LOCALBIN}/launch_polybar.sh")
UDISKIE = "udiskie"
CONKY = f"conky -c {os.path.expanduser('~/.conkyrc')}"
NM_APPLET = "nm-applet"
DUNST = "dunst"
REDSHIFT = "redshift-gtk"

AUTOSTART_LIST = [CHANGE_WALLPAPER.split(), UDISKIE.split(), NM_APPLET.split(),CONKY.split(), POLYBAR.split(), DUNST.split(), REDSHIFT.split()]

TERMINAL = "alacritty"

ICONS_PATH = os.path.expanduser("~/Local/share/icons/qtile")