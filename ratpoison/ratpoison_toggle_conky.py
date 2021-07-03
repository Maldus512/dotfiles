#!/usr/bin/env python

import re
import sys
import subprocess
import argparse
import ratpoison_workspaces


def rprun(*args):
    strargs = "".join([f"{x} " for x in args]).rstrip(" ")
    return subprocess.run(["ratpoison", "-c", strargs], stdout=subprocess.PIPE).stdout.decode("utf-8")


def setenv(variable, value):
    rprun("setenv", variable, value)


def getenv(variable):
    return rprun("getenv", variable)


def main():
    active = getenv("conky_visible").strip("\n")
    padding = [int(x) for x in rprun("set", "padding").split(" ") if x]

    if not active or active == "false":
        setenv("conky_visible", "true")
        padding[2] = 256 + 16
    else:
        setenv("conky_visible", "false")
        padding[2] = padding[0]
    
    rprun("set", "padding", padding[0], padding[1], padding[2], padding[3])



if __name__ == "__main__":
    main()
