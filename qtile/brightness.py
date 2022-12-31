from subprocess import Popen, PIPE
import notify
from environment import brightness_get, brightness_modify, BRIGHTNESS_ICON


BRIGHTNESS_TAG = "Brightness"


def show():
    notify.notify(f"{brightness_get()}%",
                  app=BRIGHTNESS_TAG, tag=BRIGHTNESS_TAG)


def get():
    brightness_get()


def modify(operation):
    try:
        res = brightness_modify(operation)
        notify.notify(f"{res}%", app=BRIGHTNESS_TAG, tag=BRIGHTNESS_TAG,
                      icon=BRIGHTNESS_ICON, progress=int(res))
    except (ValueError) as e:
        notify.notify(f"{e}", app=BRIGHTNESS_TAG, timeout=10000,
                      urgency="critical", icon=BRIGHTNESS_ICON)
