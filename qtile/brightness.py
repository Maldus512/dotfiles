from subprocess import Popen, PIPE
from libqtile.log_utils import logger
import notify

try:
    from environment import brightness_get, brightness_modify, BRIGHTNESS_ICON
except ImportError:
    logger.warning("Could not import brightness implementation")

    brightness_get = lambda: 0
    brightness_modify = lambda x: 0
    BRIGHTNESS_ICON = ""


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
