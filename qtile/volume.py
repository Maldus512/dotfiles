from subprocess import Popen, PIPE
import notify
import re
import os

AMIXER = "amixer"
ICONS = ["icon-volume-high.svg"]

MUTED_ICON = os.getenv("VOLUME_MUTED_ICON")
VOLUME_HIGH_ICON = os.getenv("VOLUME_HIGH_ICON")
VOLUME_MEDIUM_ICON = os.getenv("VOLUME_MEDIUM_ICON")
VOLUME_LOW_ICON = os.getenv("VOLUME_LOW_ICON")


def modify(operation):
    if operation < 0:
        operation = f"{abs(operation)}%-"
    else:
        operation = f"{operation}%+"

    pipe = Popen([AMIXER, "set", "Master", operation], stdout=PIPE)
    result = pipe.communicate()[0].decode()
    show(result)


def toggle():
    pipe = Popen([AMIXER, "set", "Master", "toggle"], stdout=PIPE)
    result = pipe.communicate()[0].decode()
    show(result)


def show(recap):
    left_match = re.search(
        "Front Left: Playback \d+ \[(\d+)%\] \[(\w+)\]", recap)
    right_match = re.search(
        "Front Right: Playback \d+ \[(\d+)%\] \[(\w+)\]", recap)

    if left_match and right_match:
        try:
            if left_match.group(2) == "off" and right_match.group(2) == "off":
                notify.notify("Muted", app="Volume",
                              tag=AMIXER, icon=MUTED_ICON)
            else:
                if left_match.group(2) == "off":
                    left_volume = 0
                else:
                    left_volume = left_match.group(1)

                if right_match.group(2) == "off":
                    right_volume = 0
                else:
                    right_volume = left_match.group(1)

                volume = (int(left_volume) + int(right_volume))/2

                if volume == 0:
                    icon = MUTED_ICON
                elif volume < 33:
                    icon = VOLUME_LOW_ICON
                elif volume < 66:
                    icon = VOLUME_MEDIUM_ICON
                else:
                    icon = VOLUME_HIGH_ICON

                notify.notify(f"{volume}%",
                              app="Volume", tag=AMIXER, icon=icon, progress=volume)

        except (IndexError, ValueError) as e:
            notify.notify(f"{e}", app="Volume",
                          timeout=10000, urgency="critical")
    else:
        notify.notify("Invalid amixer output!",
                      timeout=10000, urgency="critical")
