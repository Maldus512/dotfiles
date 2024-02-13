from subprocess import Popen, PIPE
import re
import os

BRIGHTNESSCTL = "brightnessctl"

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


XRANDR = "xrandr"

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
