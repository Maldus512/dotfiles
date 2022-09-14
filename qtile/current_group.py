#!/usr/bin/env python

from libqtile.command.client import InteractiveCommandClient
import sys
import signal
import threading
import os


PID_FILE = "/tmp/current_workspace_signaler_pid.txt"

event = threading.Event()


def received_usr1(signal, frame):
    event.set()


def main():
    signal.signal(signal.SIGUSR1, received_usr1)
    event.set()
    client = InteractiveCommandClient()

    with open(PID_FILE, "w") as f:
        f.write(str(os.getpid()))
    
    while True:
        if event.wait(timeout=4):
            event.clear()

        print(client.group.info()["name"])

        if not os.path.exists(PID_FILE):
            with open(PID_FILE, "w") as f:
                f.write(str(os.getpid()))


if __name__ == "__main__":
    main()
