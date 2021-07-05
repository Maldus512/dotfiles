#!/usr/bin/env python

import subprocess
import argparse


def rprun(*args):
    strargs = "".join([f"{x} " for x in args]).rstrip(" ")
    return subprocess.run(["ratpoison", "-c", strargs], stdout=subprocess.PIPE).stdout.decode("utf-8")


def message(msg):
    rprun("echo", msg)


def setenv(variable, value):
    rprun("setenv", variable, value)


def getenv(variable):
    return rprun("getenv", variable)

def workspace_name(num):
    if int(num) == 0:
        return "default"
    else:
        return f"workspace_{num}"

def workspace_dump_name(num):
    return f"{workspace_name(num)}_dump"

def workspace_data():
    try:
        workspaces = int(getenv("workspaces"))
        current_workspace = int(getenv("current_workspace"))
    except ValueError:
        workspaces = 1
        current_workspace = 0

    return (current_workspace, workspaces)

def dump_variables():
    print("workspaces", getenv("workspaces"))
    print("current_workspace", getenv("current_workspace"))

def new_workspace():
    current_workspace, workspaces = workspace_data()

    frame_dump = rprun("fdump") 
    setenv(workspace_dump_name(current_workspace), frame_dump)

    rprun("select", "-")
    rprun("only")

    rprun("gnew", workspace_name(workspaces)) 
    frame_dump = rprun("fdump") 

    current_workspace = workspaces
    workspaces += 1

    setenv("current_workspace", str(current_workspace))
    setenv("workspaces", str(workspaces))
    setenv(workspace_dump_name(current_workspace), frame_dump)

    message(f"Created new workspace: {current_workspace}")

def prepare_switch():
    current_workspace, workspaces = workspace_data()
    frame_dump = rprun("fdump") 
    setenv(workspace_dump_name(current_workspace), frame_dump)
    return (current_workspace, workspaces)


def close_switch(current_workspace):
    setenv("current_workspace", current_workspace)
    rprun("gselect", workspace_name(current_workspace))
    frame_dump = getenv(workspace_dump_name(current_workspace))
    rprun("frestore", frame_dump)

    message(f"Switched to workspace {current_workspace}")


def next_workspace():
    (current_workspace, workspaces) = prepare_switch()
    current_workspace = (current_workspace + 1) % workspaces
    close_switch(current_workspace)


def prev_workspace():
    (current_workspace, workspaces) = prepare_switch()
    if current_workspace == 0:
        current_workspace = workspaces-1
    else:
        current_workspace -= 1
    close_switch(current_workspace)


def select_workspace(workspace):
    current_workspace, workspaces = prepare_switch()
    close_switch(workspace)


def move_to_workspace(workspace):
    rprun("gmove", workspace_name(workspace)) 
    rprun("select", "-")
    select_workspace(workspace)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--create-workspace", action="store_true", help="Create a new workspace")
    parser.add_argument("-n", "--next", action="store_true", help="Move to next workspace")
    parser.add_argument("-p", "--prev", action="store_true", help="Move to previous workspace")
    parser.add_argument("-s", "--select", help="Select workspace")
    args = parser.parse_args()

    if args.create_workspace:
        new_workspace()

    if args.next:
        next_workspace()

    if args.prev:
        prev_workspace()

    if args.select:
        select_workspace(args.select)


if __name__ == "__main__":
    main()
