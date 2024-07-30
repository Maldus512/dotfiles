from subprocess import Popen
from libqtile.log_utils import logger

DUNSTIFY = "dunstify"

def notify(msg, app=None, tag=None, timeout=4000, urgency="low", icon=None, progress=None):
    cmd = [DUNSTIFY]
    if app:
        cmd += ["-a", app]
    if tag:
        cmd += ["-h", f"string:x-dunst-stack-tag:{tag}"]
    if icon:
        cmd += ["-i", f"{icon}"]
    if progress:
        cmd += ["-h", f"int:value:{progress}"]
    cmd += ["-u", f"{urgency}"]
    cmd += ["-t", f"{timeout}"]
    cmd += [msg]

    logger.warning(f"Running {cmd}")
    res = Popen(cmd).communicate()
    logger.warning(f"result {res}")
