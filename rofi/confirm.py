#!/usr/bin/env python

import re
import sys
import subprocess
import argparse


def main():
    parser = argparse.ArgumentParser(
        description="Navigate through workspaces and windows")
    parser.add_argument("choice", nargs="?",
                        help="Chosen option", default=None)
    args = parser.parse_args()

    client = InteractiveCommandClient()

    if args.choice == None:
        print("Yes")
        print("No")
    else:
        pass


if __name__ == "__main__":
    main()
