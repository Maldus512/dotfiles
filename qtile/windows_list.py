#!/usr/bin/env python

import re
import sys
import subprocess
import argparse
import signal
import threading
import os
from libqtile.command.client import InteractiveCommandClient
from libqtile.command.base import CommandError

PID_FILE = "/tmp/.qtile_windows_list_pid.txt"




def main():
    event = threading.Event()

    def received_usr1(signal, frame):
        nonlocal event
        event.set()

    signal.signal(signal.SIGUSR1, received_usr1)
    # setenv("windows_list_pid", os.getpid())
    event.set()

    client = InteractiveCommandClient()

    while True:
        if event.wait(timeout=8):
            event.clear()

        try:
            info = client.group.info()
            current_group = info["label"]
            windows_details_list = client.windows()
            current_window_id = client.window.info()["id"]
            windows = [(w["id"], w["name"])
                       for w in windows_details_list if w["group"] == current_group]

            print("%{-u} | ", end="")
            for (id, name) in windows:
                if name == None:
                    name = "<Nameless window>"

                if len(name) > 20:
                    name = name[:20]

                if id == current_window_id:
                    print(f"%{{+u}}{name}%{{-u}}", end=" | ")
                else:
                    print(f"{name}", end=" | ")
        except CommandError:
            pass
        print()
    print("ERROR")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Polybar windows list")
    parser.add_argument("-s", "--signal", action="store_true",
                        help="Signal an existing PID")
    args = parser.parse_args()

    if args.signal:
        with open(PID_FILE, "r") as f:
            pid = int(f.read())
            os.kill(pid, signal.SIGUSR1)
    else:
        with open(PID_FILE, "w") as f:
            f.write(str(os.getpid()))
        main()
