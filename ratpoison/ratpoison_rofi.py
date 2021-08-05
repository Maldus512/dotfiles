#!/usr/bin/env python

import re
import sys
import subprocess
import argparse
import ratpoison_workspaces


def rprun(*args):
    strargs = "".join([f"{x} " for x in args]).rstrip(" ")
    return subprocess.run(["ratpoison", "-c", strargs], stdout=subprocess.PIPE).stdout.decode("utf-8")


def get_current_group():
    groups = [x.strip("\"") for x in rprun("groups").split("\n") if x]
    for group in groups:
        if found := re.compile(r"^([0-9]+)\*").search(group):
            selected = int(found.group(1))
            return selected
    return 0


def get_groups():
    current_group = get_current_group()
    rawgroups = rprun("groups")
    groups = []
    for group in rawgroups.split("\n"):
        group = group.strip("\"")
        if found := re.compile("^([0-9]+)").search(group):
            selected = int(found.group(1))
            rprun("gselect", selected)
            windows = [x.strip("\"") for x in rprun("windows").split("\n") if x]
            wnames = []
            for window in windows:
                if found := re.compile(r"^[0-9]+#([\*|\+|-])#(.+)").search(window):
                    status = found.group(1)
                    if status == "*":
                        priority = 1
                    elif status == "+":
                        priority = 2
                    else:
                        priority = 3

                    wnames.append((priority, found.group(2)))

            groups.append(f"{selected} - " + ", ".join([x[1] for x in sorted(wnames, key=lambda y: y[0])]))

        else:
            groups.append(group)

    rprun("gselect", current_group)
    return groups


def get_window_name(window):
    if name := re.compile(r"^[0-9]+#[\*\+\-]#(.+)$").search(window):
        return name.group(1)
    else:
        return window


def main():
    parser = argparse.ArgumentParser(description="Navigate through workspaces and windows")
    parser.add_argument("-w", "--windows", action="store_true", help="switch through windows")
    parser.add_argument("-d", "--desktops", action="store_true", help="switch through workspaces")
    parser.add_argument("-s", "--send-to-desktop", dest="send_to_desktop", action="store_true", help="send current window to selected workspace")
    parser.add_argument("choice", nargs="?", help="Chosen option", default=None)
    args = parser.parse_args()

    if args.choice == None:
        if args.windows:
            windows = rprun("windows")
            for window in [x.strip("\"") for x in windows.split("\n") if len(x)]:
                print(get_window_name(window))
        elif args.desktops or args.send_to_desktop:
            for group in get_groups():
                print(group)

    else:
        if args.windows:
            windows = rprun("windows")
            for window in [x.strip("\"") for x in windows.split("\n") if len(x)]:
                if get_window_name(window) == args.choice:
                    if found := re.compile("^[0-9]+").search(window):
                        selected = int(found.group(0))
                        rprun("select", selected)
        elif args.send_to_desktop:
            if found := re.compile("^[0-9]+").search(args.choice):
                selected = int(found.group(0))
                ratpoison_workspaces.move_to_workspace(selected)
        elif args.desktops:
            if found := re.compile("^[0-9]+").search(args.choice):
                selected = int(found.group(0))
                ratpoison_workspaces.select_workspace(selected)



if __name__ == "__main__":
    main()
