#!/usr/bin/env python -u

import re
import sys
import subprocess
import argparse
import signal
import threading
import os


event = threading.Event()


def rprun(*args):
    strargs = "".join([f"{x} " for x in args]).rstrip(" ")
    return subprocess.run(["ratpoison", "-c", strargs], stdout=subprocess.PIPE).stdout.decode("utf-8")


def setenv(variable, value):
    rprun("setenv", variable, value)


def getenv(variable):
    return rprun("getenv", variable)


def received_usr1(signal, frame):
    event.set()


def main():
    signal.signal(signal.SIGUSR1, received_usr1)
    setenv("windows_list_pid", os.getpid())
    event.set()
    counter = 0

    while True:
        counter += 1
        if event.wait(timeout=4):
            event.clear()

        output = rprun("windows")

        if output.replace("\n", "") == "No managed windows":
            print(" ")
            continue
        
        windows = [x.strip("\"").replace("\n", "") for x in output.split("\n") if x]
        cleanwindows = []

        for window in windows:
            if found := re.compile(r"^[0-9]+#([\*|\-|\+])#(.+)").search(window):
                if found.group(1) == "*":
                    selected = True
                else:
                    selected = False
                cleanwindows.append((selected, found.group(2)))
            else:
                cleanwindows.append((False, window))

        print("%{-u} | ", end="")
        for (active, name) in cleanwindows:
            if len(name) > 16:
                name = name[:16]
            if active:
                print(f"%{{+u}}{name}%{{-u}}", end=" | ")
            else:
                print(f"{name}", end=" | ")
        print(counter, end="")
        print()

    print("ERROR")

if __name__ == "__main__":
    main()
