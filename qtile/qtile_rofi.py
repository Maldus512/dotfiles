#!/usr/bin/env python

import re
import sys
import subprocess
import argparse
import libqtile
from libqtile.command.client import InteractiveCommandClient


def group_names(client):
    result = {}

    for group in client.groups().keys():
        if group == "~/":
            continue

        try:
            name = f"{group:<16}: {client.group[group].window.info()['name']}"
        except libqtile.command.base.CommandError:
            name = group
        result[name] = group

    return result


def main():
    parser = argparse.ArgumentParser(description="Navigate through workspaces and windows")
    parser.add_argument("-w", "--windows", action="store_true", help="switch through windows")
    parser.add_argument("-d", "--desktops", action="store_true", help="switch through workspaces")
    parser.add_argument("-s", "--send-to-desktop", dest="send_to_desktop", action="store_true", help="send current window to selected workspace")
    parser.add_argument("choice", nargs="?", help="Chosen option", default=None)
    args = parser.parse_args()

    client = InteractiveCommandClient()

    if args.choice == None:
        if args.windows:
            windows = client.group.info()["windows"]
            for window in windows:
                print(window)
        elif args.desktops or args.send_to_desktop:
            names = group_names(client)
            for name in names.keys():
                print(name)

    else:
        if args.windows:
            pass
        elif args.send_to_desktop:
            pass
        elif args.desktops:
            names = group_names(client)
            client.group[names[args.choice]].toscreen()


if __name__ == "__main__":
    main()
