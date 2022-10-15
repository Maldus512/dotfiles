from subprocess import Popen, PIPE
import notify
import re

BRIGHTNESSCTL = "brightnessctl"
BRIGHTNESS_ICON = "/usr/share/icons/Arc/status/symbolic/brightness-display-symbolic.svg"

def show():
    notify.notify(f"{get()}%", app="Brightness", tag=BRIGHTNESSCTL)


def get():
    pipe = Popen([BRIGHTNESSCTL, "g"], stdout=PIPE)
    try:
        return int(pipe.communicate()[0].decode().strip("\n"))
    except IndexError:
        return 100


def modify(operation):
    if operation < 0:
        operation = f"{abs(operation)}-"
    else:
        operation = f"+{operation}"

    pipe = Popen([BRIGHTNESSCTL, "s", operation], stdout=PIPE)
    result = pipe.communicate()[0].decode()

    if match := re.search("Current brightness: (\d+)", result):
        try:
            percentage = match.group(1)
            notify.notify(f"{percentage}%", app="Brightess", tag=BRIGHTNESSCTL, icon=BRIGHTNESS_ICON, progress=int(percentage))
        except (IndexError, ValueError) as e:
            notify.notify(f"{e}", app="Brightness", timeout=10000, urgency="critical", icon=BRIGHTNESS_ICON)


