#!/usr/bin/env python
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
from gi.repository import Gtk, Gdk, GdkPixbuf
import gi
gi.require_version('Gtk', '3.0')

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

    def from_json(data):
        def icon_from_json(data):
            if not data["icon"]:
                return None
            else:
                try:
                    return Icon(data["icon"]["data"], data["icon"]["width"], data["icon"]["height"])
                except KeyError:
                    return None

        return Group(data["name"], [Window(w["x"], w["y"], w["width"], w["height"], icon_from_json(w)) for w in data["windows"]])
        # return Group(data["name"], [])


def grid_from_json(string):
    try:
        return [
            [Group.from_json(dict_group) for dict_group in dict_row] for dict_row in json.loads(string)
        ]
    except json.decoder.JSONDecodeError as e:
        return [[Group("Error", [str(e)])]]


class DesktopGridWindow(Gtk.Window):

    def __init__(self, groups_grid, current_group, screen_width=None, screen_height=None):
        DESKTOP_PREVIEW_WIDTH = 100
        DESKTOP_PREVIEW_HEIGHT = 70
        SELECTED_BORDER_WIDTH = 4
        NOT_SELECTED_BORDER_WIDTH = 1

        def desktop_frame(name, windows=[], selected=False):
            if selected:
                preview_width = DESKTOP_PREVIEW_WIDTH - SELECTED_BORDER_WIDTH*2
                preview_height = DESKTOP_PREVIEW_HEIGHT - SELECTED_BORDER_WIDTH*2
            else:
                preview_width = DESKTOP_PREVIEW_WIDTH - NOT_SELECTED_BORDER_WIDTH*2
                preview_height = DESKTOP_PREVIEW_HEIGHT - NOT_SELECTED_BORDER_WIDTH*2

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
                    pil_image = Image.frombytes(
                        "RGBA", (icon.width, icon.height), bytes(icon.data))

                    #data_array = array.array('B', icon.data)
                    new_data = list(sum(pil_image.getdata(), ()))
                    data_array = array.array('B', new_data)

                    img = cairo.ImageSurface.create_for_data(
                        data_array, cairo.FORMAT_ARGB32, icon.width, icon.height
                    )
                    #pixbuf = GdkPixbuf.Pixbuf.new_from_data(copy.deepcopy(bytearray(icon.data)), GdkPixbuf.Colorspace.RGB, False, 8, icon.width, icon.height, 0)
                    #pixbuf = pixbuf.scale_simple(width/2, height/2, Gdk.INTERP_BILINEAR)

                    image = Gtk.Image.new_from_surface(img)
                    #image = Gtk.Image.new_from_pixbuf(pixbuf)
                    image.set_vexpand(True)
                    image.set_hexpand(True)
                    window_frame.add(image)
                    # frame.add(image)

                board.put(window_frame, int(x), int(y))

            label = Gtk.Label()
            label.set_markup(f"<span size=\"16000\">{name}</span>")

            frame = Gtk.Frame()
            frame.set_label_align(.5, 0)
            frame.set_label_widget(label)

            if selected:
                frame.set_name("selected")
            else:
                frame.set_name("not_selected")

            frame.set_size_request(preview_width, preview_height)

            board = Gtk.Fixed()
            board.set_hexpand(True)
            board.set_vexpand(True)

            border_width = SELECTED_BORDER_WIDTH if selected else NOT_SELECTED_BORDER_WIDTH

            if screen_width and screen_height:
                for window in windows:
                    print(window)
                    if res := scale_window(window.x, window.y, window.width, window.height):
                        (x, y, width, height) = res
                        add_window(x, y, width, height, window.icon, board)

            elif windows:
                (x, y, width, height) = ((DESKTOP_PREVIEW_WIDTH-border_width *
                                          2 - 20)/2, (20 - border_width*2)/2, 20, 20)

                add_window(x, y, width, height, None, board)

            frame.add(board)

            return frame

        super().__init__(title="Desktop grid", window_position=Gtk.WindowPosition.CENTER_ALWAYS)
        #self.set_default_size(320, 240)

        BORDER_COLOR = os.getenv("MAIN_THEME_COLOR")
        HIGHLIGHT_COLOR = os.getenv("FONT_THEME_COLOR")

        if not BORDER_COLOR:
            BORDER_COLOR = "purple"
        if not HIGHLIGHT_COLOR:
            HIGHLIGHT_COLOR = "green"

        style_provider = Gtk.CssProvider()
        style_provider.load_from_data(f"""
            label {{
                margin-top: 4px;
            }}

            frame {{
                color: {HIGHLIGHT_COLOR};
                background-color: black;
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
                border-width: {SELECTED_BORDER_WIDTH}px;
            }}
                                            
            #not_selected > border {{
                border-width: {NOT_SELECTED_BORDER_WIDTH}px;
                border-color: gray;
            }}

            #window > border {{
                border-width: 1px;
                border-color: gray;
            }}
                                            """.encode())

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
                grid.attach(desktop_frame(group.name, windows=group.windows, selected=group.name ==
                            current_group), row_index, column_index, 1, 1)
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


def show(groups_grid, current_group, screen_width, screen_height):
    with open(PID_FILE, "w") as f:
        f.write(str(os.getpid()))

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
    parser.add_argument("-c", "--current", type=str, help="Current desktop")
    parser.add_argument("-g", "--grid", required=True, type=str,
                        help="Desktop grid (in json)")
    parser.add_argument("-W", "--screen-width", type=int,
                        help="Current screen width")
    parser.add_argument("-H", "--screen-height", type=int,
                        help="Current screen height")
    args = parser.parse_args()

    grid = grid_from_json(args.grid)

    try:
        with open(PID_FILE, "r") as f:
            pid = int(f.read())

            if check_pid(pid):
                os.kill(pid, signal.SIGKILL)

    except (FileNotFoundError, ValueError):
        pass

    show(grid, args.current, args.screen_width, args.screen_height)


if __name__ == "__main__":
    main()
