from subprocess import Popen, PIPE
import notify

try:
    from environment import volume_show, volume_modify, volume_toggle
except ImportError:
    volume_show = lambda: 0
    volume_modify = lambda x: 0
    volume_toggle = lambda: 0


def show():
    volume_show()


def toggle():
    volume_toggle()


def modify(operation):
    volume_modify(operation)
