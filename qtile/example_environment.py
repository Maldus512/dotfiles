from subprocess import Popen, PIPE
import re
import os

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
REST = os.path.expanduser(f"~/Projects/pasticci/101010/101010")

AUTOSTART_LIST = [CHANGE_WALLPAPER.split(), UDISKIE.split(), NM_APPLET.split(
), CONKY.split(), POLYBAR.split(), DUNST.split(), POLKIT.split(), REST.split()]

TERMINAL = "alacritty"

ICONS_PATH = os.path.expanduser("~/Local/share/icons/qtile")


BRIGHTNESSCTL = "brightnessctl"
XRANDR = "xrandr"
BRIGHTNESS_ICON = "/usr/share/icons/Arc/status/symbolic/brightness-display-symbolic.svg"


def brightness_get_xrandr():
    pipe = Popen([XRANDR, "--verbose"], stdout=PIPE)
    try:
        result = pipe.communicate()[0].decode()
        result = result.split("DP-0 connected")[1]
        if match := re.search("Brightness: (\d+.\d+)", result):
            return int(float(match.group(1)) * 100)
    except (ValueError, IndexError):
        return 100


def brightness_modify_xrandr(operation):
    value = brightness_get()

    try:
        pipe = Popen([XRANDR, "--output", "DP-0", "--brightness",
                     str(float(value+operation)/100.)], stdout=PIPE)
        return brightness_get()
    except ValueError as e:
        raise e
    except IndexError as e:
        raise ValueError(str(e))


def brightness_get_brightnessctl():
    pipe = Popen([BRIGHTNESSCTL, "g"], stdout=PIPE)
    try:
        return int(pipe.communicate()[0].decode().strip("\n"))
    except IndexError:
        return 100


def brightness_modify_brightnessctl(operation):
    if operation < 0:
        operation = f"{abs(operation)}-"
    else:
        operation = f"+{operation}"

    pipe = Popen([BRIGHTNESSCTL, "s", operation], stdout=PIPE)
    result = pipe.communicate()[0].decode()

    if match := re.search("Current brightness: (\d+)", result):
        try:
            return int(match.group(1))
        except ValueError as e:
            raise e
        except IndexError as e:
            raise ValueError(str(e))


# Brightness configuration

brightness_get = brightness_get_xrandr
brightness_modify = brightness_modify_xrandr

