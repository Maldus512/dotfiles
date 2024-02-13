#!/usr/bin/env python
from libqtile.command.client import InteractiveCommandClient
import libqtile
from PIL import Image
import array
import cairo
import signal
import threading
import os
import time
import argparse
import json
from dataclasses import dataclass
from typing import List, Optional
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GdkPixbuf


PID_FILE = "/tmp/.show_groups_pid.txt"


@dataclass
class Icon:
    data: List[int]
    width: int
    height: int


@dataclass
class Window:
    x: int
    y: int
    width: int
    height: int
    icon: Optional[Icon]


@dataclass
class Group:
    name: str
    windows: List[Window]


class DesktopGridWindow(Gtk.Window):
    SELECTED_BORDER_WIDTH = 4
    NOT_SELECTED_BORDER_WIDTH = 1

    def desktop_frame(name, windows=[], selected=False, screen_width=None, screen_height=None, screen_index=None):
        DESKTOP_PREVIEW_WIDTH = 100
        DESKTOP_PREVIEW_HEIGHT = 70

        if selected:
            preview_width = DESKTOP_PREVIEW_WIDTH - \
                DesktopGridWindow.SELECTED_BORDER_WIDTH*2
            preview_height = DESKTOP_PREVIEW_HEIGHT - \
                DesktopGridWindow.SELECTED_BORDER_WIDTH*2
        else:
            preview_width = DESKTOP_PREVIEW_WIDTH - \
                DesktopGridWindow.NOT_SELECTED_BORDER_WIDTH*2
            preview_height = DESKTOP_PREVIEW_HEIGHT - \
                DesktopGridWindow.NOT_SELECTED_BORDER_WIDTH*2

        def scale(value, first_size, second_size):
            return value*second_size/first_size

        def scale_window(x, y, width, height):
            if screen_width == None or screen_height == None:
                return None

            scaled_x = scale(x, screen_width, preview_width)
            scaled_width = scale(width, screen_width, preview_width)
            scaled_y = scale(y, screen_height, preview_height)
            scaled_height = scale(height, screen_height, preview_height)

            return (scaled_x, scaled_y, scaled_width, scaled_height)

        def add_window(x, y, width, height, icon, board):
            if x < 0:
                x = 0
            if y < 0:
                y = 0
            if width < 1:
                width = 1
            if height < 1:
                height = 1

            window_frame = Gtk.Frame()
            window_frame.set_name("window")
            window_frame.set_size_request(width, height)

            if icon:
                pixbuf = GdkPixbuf.Pixbuf.new_from_file(icon)
                if width > height:
                    side = height - 8
                else:
                    side = width - 8
                pixbuf = pixbuf.scale_simple(
                    side, side, GdkPixbuf.InterpType.BILINEAR)

                image = Gtk.Image.new_from_pixbuf(pixbuf)
                image.set_vexpand(True)
                image.set_hexpand(True)
                window_frame.add(image)

            board.put(window_frame, int(x), int(y))

        frame = Gtk.Frame()

        if selected:
            frame.set_name("selected")
        else:
            frame.set_name("not_selected")

        frame.set_size_request(preview_width, preview_height )

        if screen_index != None:
            pixbuf = GdkPixbuf.Pixbuf.new_from_file(os.path.expanduser(f"~/Pictures/Wallpapers/auto{screen_index+1}.png"))
            pixbuf = pixbuf.scale_simple(preview_width, preview_height, GdkPixbuf.InterpType.BILINEAR)

            image = Gtk.Image.new_from_pixbuf(pixbuf)
            image.set_vexpand(True)
            image.set_hexpand(True)
            frame.add(image)

        board = Gtk.Fixed()
        board.set_name("windows_board")
        board.set_hexpand(True)
        board.set_vexpand(True)

        border_width = DesktopGridWindow.SELECTED_BORDER_WIDTH if selected else DesktopGridWindow.NOT_SELECTED_BORDER_WIDTH

        if screen_width and screen_height:
            for window in windows:
                if res := scale_window(window.x, window.y, window.width, window.height):
                    (x, y, width, height) = res
                    add_window(x, y, width, height, window.icon, board)

        elif windows:
            (x, y, width, height) = ((DESKTOP_PREVIEW_WIDTH-border_width *
                                      2 - 20)/2, (20 - border_width*2)/2, 20, 20)

            add_window(x, y, width, height, None, board)

        frame.add(board)

        return frame

    def __init__(self, groups_grid, current_group, screen_width=None, screen_height=None, screen_index=None):
        BORDER_COLOR = os.getenv("MAIN_THEME_COLOR", default="#FFFFFF")
        HIGHLIGHT_COLOR = os.getenv("FONT_THEME_COLOR", default="#FFFFFF")
        if screen_index != None:
            DESKTOP_COLOR = "rgba(0,0,0,0)"
        else:
            DESKTOP_COLOR = os.getenv("MAIN_THEME_COLOR_DARK", default="#000000")

        CSS = f"""
            label {{
                margin-top: 4px;
            }}

            frame {{
                color: {HIGHLIGHT_COLOR};
                background-color: {DESKTOP_COLOR};
                padding: 1px;
            }}

            frame > border {{
                border-style:solid;
                border-width: 2px;
            }}

            #base > border {{
                border-color: {BORDER_COLOR};
            }}

            #selected > border {{ 
                border-color: {HIGHLIGHT_COLOR};
                border-width: {DesktopGridWindow.SELECTED_BORDER_WIDTH}px;
            }}
                                            
            #not_selected > border {{
                border-width: {DesktopGridWindow.NOT_SELECTED_BORDER_WIDTH}px;
                border-color: gray;
            }}

            #window > border {{
                border-width: 1px;
                border-color: gray;
            }}

            #window  {{
                border-width: 1px;
                border-color: gray;
                background-color: rgba(0, 0, 0, 0.5);
            }}
                                            """.encode()

        super().__init__(title="Desktop grid", window_position=Gtk.WindowPosition.CENTER_ALWAYS)

        if not BORDER_COLOR:
            BORDER_COLOR = "purple"
        if not HIGHLIGHT_COLOR:
            HIGHLIGHT_COLOR = "green"

        style_provider = Gtk.CssProvider()
        style_provider.load_from_data(CSS)

        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            style_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        base = Gtk.Frame()
        base.set_name("base")

        grid = Gtk.Grid()

        column_index = 0
        for row in groups_grid:
            row_index = 0
            for group in row:
                grid.attach(DesktopGridWindow.desktop_frame(group.name, group.windows, group.name ==
                            current_group, screen_width, screen_height, screen_index), row_index, column_index, 1, 1)
                row_index += 1

            column_index += 1

        base.add(grid)
        self.add(base)


def autoquit(window):
    time.sleep(1)
    Gtk.main_quit()


def check_pid(pid):
    try:
        os.kill(pid, 0)
    except OSError:
        return False
    else:
        return True


def groups_grid_from_list(groups, windows, icons_path):
    #TODO: focus history
    icons_config = {}
    if icons_path:
        with open(os.path.join(icons_path, "icons.json"), "r") as f:
            icons_config = json.load(f)

    window_to_icon = {}
    for k in icons_config:
        for winclass in icons_config[k]:
            window_to_icon[winclass] = k

    def get_window_icon(window_classes):
        if not icons_path:
            return None

        for winclass in window_classes:
            try:
                return os.path.join(icons_path, window_to_icon[winclass])
            except KeyError:
                continue

        return None


    grid = []

    grid_side = 0
    num_groups = 0
    grid_row = 0

    for group in groups:
        num_groups += 1

        if num_groups > grid_side**2:
            grid.append([])
            grid_side += 1
            grid_row = 0
        elif len(grid[grid_row]) >= grid_side:
            grid_row += 1

        windows_by_id = {}
        focused = group["focus"]
        focused_window_id = None
        for wname in group["windows"]:
            found_windows = [w for w in windows if w["name"]
                             == wname and w["group"] == group["name"]]

            for found in found_windows:
                if found["name"] == focused:
                    focused_window_id = found["id"]

                windows_by_id[found["id"]] = Window(
                    found["x"], found["y"], found["width"], found["height"], get_window_icon(found["wm_class"]))

        # Make sure the focused window is the last one rendering
        if focused_window_id:
            focused_window = windows_by_id.pop(focused_window_id, None)
            windows_data = list(windows_by_id.values()) + [ focused_window]
        else:
            windows_data = list(windows_by_id.values())

        grid[grid_row].append(Group(group["name"], windows_data))

    return grid


def get_groups(client, ignore=[]):
    return [g for g in client.groups().values() if not g["name"] in ignore]


def show(screen_width, screen_height, ignore, icons_path):
    if not ignore:
        ignore = []

    with open(PID_FILE, "w") as f:
        f.write(str(os.getpid()))

    client = InteractiveCommandClient()

    groups_grid = groups_grid_from_list(
        get_groups(client, ignore), client.windows(), icons_path)
    current_group = client.group.info()["name"]

    win = DesktopGridWindow(groups_grid, current_group,
                            screen_width, screen_height)

    win.connect("destroy", Gtk.main_quit)
    win.connect('button-press-event', lambda widget, event: Gtk.main_quit())
    win.set_keep_above(True)
    win.set_type_hint(Gdk.WindowTypeHint.UTILITY)
    win.set_type_hint(Gdk.WindowTypeHint.DOCK)
    # win.set_type_hint(Gdk.WindowTypeHint.DESKTOP)
    win.show_all()

    thread = threading.Thread(target=autoquit, args=[win])
    thread.daemon = True
    thread.start()

    Gtk.main()


def main():
    parser = argparse.ArgumentParser(
        description="Show a desktop grid")
    parser.add_argument("-W", "--screen-width", type=int,
                        help="Current screen width")
    parser.add_argument("-H", "--screen-height", type=int,
                        help="Current screen height")
    parser.add_argument("-i", "--ignore", type=str, nargs="+",
                        help="Ignore these groups")
    parser.add_argument("-p", "--path", type=str,
                        help="Theme path")
    args = parser.parse_args()

    try:
        with open(PID_FILE, "r") as f:
            pid = int(f.read())

            if check_pid(pid):
                os.kill(pid, signal.SIGKILL)

    except (FileNotFoundError, ValueError):
        pass

    show(args.screen_width, args.screen_height, args.ignore, args.path)


if __name__ == "__main__":
    main()
