from subprocess import Popen, PIPE
import notify
import re
import os

PACTL = "pactl"
AMIXER = "amixer"
ICONS = ["icon-volume-high.svg"]

MUTED_ICON = os.getenv("VOLUME_MUTED_ICON")
VOLUME_HIGH_ICON = os.getenv("VOLUME_HIGH_ICON")
VOLUME_MEDIUM_ICON = os.getenv("VOLUME_MEDIUM_ICON")
VOLUME_LOW_ICON = os.getenv("VOLUME_LOW_ICON")


def pactl_modify(operation):
    if operation < 0:
        operation = f"-{abs(operation)}%"
    else:
        operation = f"+{operation}%"

    pipe = Popen([PACTL, "set-sink-volume", "@DEFAULT_SINK@", operation], stdout=PIPE)
    pipe.communicate()[0].decode()
    pactl_show()


def pactl_toggle():
    pipe = Popen([PACTL, "set-sink-mute", "@DEFAULT_SINK@", "toggle"], stdout=PIPE)
    pipe.communicate()[0].decode()
    pactl_show()


def pactl_show():
    pipe = Popen([PACTL, "get-sink-volume", "@DEFAULT_SINK@"], stdout=PIPE)
    volume_input = pipe.communicate()[0].decode()

    volume_match = re.search(
            "Volume: front-left: \d+ /\s+(\d+)% / -?\d+\.\d+ dB,\s+front-right: \d+ /\s+(\d+)% / .*", volume_input)

    pipe = Popen([PACTL, "get-sink-mute", "@DEFAULT_SINK@"], stdout=PIPE)
    mute_input = pipe.communicate()[0].decode()

    mute_match = re.search(
            "Mute: (yes|no)", mute_input)

    if volume_match and mute_match:
        try:
            if mute_match.group(1) == "yes":
                notify.notify("Muted", app="Volume",
                              tag=PACTL, icon=MUTED_ICON)
            else:
                left_volume = volume_match.group(1)
                right_volume = volume_match.group(2)

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
                              app="Volume", tag=PACTL, icon=icon, progress=volume)

        except (IndexError, ValueError) as e:
            notify.notify(f"{e}", app="Volume",
                          timeout=10000, urgency="critical")
    else:
        notify.notify("Invalid pactl output!",
                      timeout=10000, urgency="critical")


def amixer_modify(operation):
    if operation < 0:
        operation = f"{abs(operation)}%-"
    else:
        operation = f"{operation}%+"

    pipe = Popen([AMIXER, "set", "Master", operation], stdout=PIPE)
    result = pipe.communicate()[0].decode()
    amixer_show(result)


def amixer_toggle():
    pipe = Popen([AMIXER, "set", "Master", "toggle"], stdout=PIPE)
    result = pipe.communicate()[0].decode()
    amixer_show(result)


def amixer_show(recap):
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
