#!/usr/bin/env python

import re
import sys
import subprocess
import argparse
import libqtile
from libqtile.command.client import InteractiveCommandClient


def group_names(client, others=False):
    result = {}

    current_group = client.group.info()["name"]

    for group in client.groups().keys():
        if group == "~/":
            continue

        if others and group == current_group:
            continue

        try:
            info = client.group[group].info()
            windows = info["windows"]
            focus = info["focus"]

            if focus in windows:
                windows.remove(focus)
                windows = [focus] + windows

            name = f"{group:<12}: {', '.join(windows)}"
        except libqtile.command.base.CommandError:
            name = group
        result[name] = group

    return (result, current_group)


def main():
    parser = argparse.ArgumentParser(
        description="Navigate through workspaces and windows")
    parser.add_argument("-w", "--windows", nargs="*",
                        help="switch through windows")
    parser.add_argument("-d", "--desktops", action="store_true",
                        help="switch through workspaces")
    parser.add_argument("-s", "--send-to-desktop", dest="send_to_desktop",
                        action="store_true", help="send current window to selected workspace")
    parser.add_argument("choice", nargs="?",
                        help="Chosen option", default=None)
    args = parser.parse_args()

    client = InteractiveCommandClient()

    if args.choice == None:
        if args.windows != None:
            if len(args.windows) == 0:
                windows = client.group.info()["windows"]
                for window in windows:
                    print(window)
            else:
                for window in args.windows:
                    print(window)
        elif args.desktops or args.send_to_desktop:
            names, current_group = group_names(
                client, others=args.send_to_desktop != None)
            groups = []
            for name in names.keys():
                groups.append(names[name])
                print(name)

            try:
                active = groups.index(current_group)
                print(f"\0active\x1f{active}")
            except ValueError:
                pass

        if args.send_to_desktop:
            print("\0prompt\x1fSend to group")

    else:
        if args.windows != None:
            pass
        elif args.send_to_desktop:
            names, _ = group_names(client)
            try:
                client.window.togroup(names[args.choice])
                client.group[names[args.choice]].toscreen()
            except KeyError:
                print(f"Group not found: {args.choice}")
        elif args.desktops:
            names, _ = group_names(client)
            try:
                client.group[names[args.choice]].toscreen()
            except KeyError:
                print(f"Group not found: {args.choice}")


if __name__ == "__main__":
    main()
