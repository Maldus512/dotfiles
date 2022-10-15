from typing import List  # noqa: F401

from libqtile import bar, layout
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile import hook
from libqtile.log_utils import logger
from libqtile.command.client import InteractiveCommandClient
from libqtile import qtile
import json

import os
import signal
from subprocess import Popen

import environment
import notify
import brightness
import volume
from floating_window_snapping import move_snap_window


SUPER = "mod4"
ALT = "mod1"
CONTROL = "control"
SHIFT = "shift"
SCRATCHPAD = "~/"

terminal = guess_terminal()
NAMES = ["Carter", "Catherine", "Jorge", "Emile", "Jun", "Six", "Mimley", "Maureen", "Honoria", "Theresa", "Elijah", "Gladia", "Daneel", "Giskard",
         "Penellaphe", "Ian", "Coralena", "Leopold"]

MARGIN = [2, 2, 4, 2]
BORDER_COLOR = os.getenv("MAIN_THEME_COLOR")


def groups_grid(groups):
    def window_dict(win):
        x, y = win.getposition()
        width, height = win.getsize()

        if not getattr(win, "icons", False):
            icon = None
        else:
            icons = sorted(
                iter(win.icons.items()),
                key=lambda x: abs(int(x[0].split("x")[0])),
            )
            #logger.warning([i[0] for i in icons])

            icon_width, icon_height = map(int, icons[0][0].split("x"))

            icon = {"data": icons[0][1].tolist(
            ), "width": icon_width, "height": icon_height}

        return {"x": x, "y": y, "width": width, "height": height, "icon": None}

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

        grid[grid_row].append({"name": group.name, "windows": [
                              window_dict(w) for w in group.windows]})

    return grid


def toggle_gap(qtile):
    # TODO: get conky width
    if qtile.current_screen.right.size == 272:
        qtile.current_screen.right.size = 0
    else:
        qtile.current_screen.right.size = 272
    qtile.current_group.layout_all()


def new_group(qtile):
    index = len(qtile.groups)

    new_name = f"Desktop {index+1}"

    for name in NAMES:
        if not name in [g.name for g in qtile.groups]:
            new_name = name
            break

    qtile.add_group(new_name)
    # make sure the group is persistent
    qtile.dgroups.groups_map[new_name].persist = True
    qtile.current_screen.set_group(qtile.groups[-1])


def delete_group(qtile):
    group_to_delete = qtile.current_screen.group.name
    new_group_index = [g.name for g in qtile.groups].index(group_to_delete) - 1
    qtile.current_screen.set_group(qtile.groups[new_group_index])
    qtile.delete_group(group_to_delete)


def next_group_in_grid(qtile, horizontal_shift, vertical_shift):
    def find_indexes(grid, current):
        index_row = 0
        index_col = 0

        for row in grid:
            index_col = 0
            for group in row:
                if group["name"] == current:
                    return (index_row, index_col)
                else:
                    index_col += 1
            index_row += 1

        return None

    def cycle(value, low, high):
        if value < low:
            return high
        if value > high:
            return low
        else:
            return value

    try:
        current = qtile.current_group.name
    except AttributeError as e:
        logger.warning(str(e))
        return ""

    grid = groups_grid([g for g in qtile.groups if g.name != SCRATCHPAD])

    current_row, current_col = find_indexes(grid, current)

    next_col = cycle(current_col + horizontal_shift,
                     0, len(grid[current_row])-1)

    max_row = 0
    for index_row in range(len(grid)):
        if len(grid[index_row]) > current_col:
            max_row = index_row
        else:
            break

    next_row = cycle(current_row + vertical_shift, 0, max_row)
    next_group = grid[next_row][next_col]["name"]
    return next_group


@lazy.function
def switch_to_next_group_in_grid(qtile, horizontal_shift, vertical_shift):
    next_group = next_group_in_grid(qtile, horizontal_shift, vertical_shift)
    qtile.groups_map[next_group].cmd_toscreen()


@lazy.function
def move_window_to_next_group_in_grid(qtile, horizontal_shift, vertical_shift):
    if qtile.current_window:
        next_group = next_group_in_grid(
            qtile, horizontal_shift, vertical_shift)
        qtile.current_window.cmd_togroup(next_group)
        qtile.groups_map[next_group].cmd_toscreen()


@ lazy.window.function
def resize_floating_window(w, width: int = 0, height: int = 0):
    w.cmd_set_size_floating(w.width + width, w.height + height)


@ lazy.window.function
def move_floating_window(window, x: int = 0, y: int = 0):
    new_x = window.float_x + x
    new_y = window.float_y + y
    window.cmd_set_position_floating(new_x, new_y)


@ hook.subscribe.startup_once
def autostart():
    for cmd in environment.AUTOSTART_LIST:
        Popen(cmd)


def show_groups_grid(qtile, current_group=None):
    if not current_group:
        try:
            current_group = qtile.current_group.name
        except AttributeError as e:
            logger.warning(str(e))

    current_screen = None
    try:
        current_screen = qtile.current_screen
    except AttributeError as e:
        logger.warning(str(e))

    grid = groups_grid([g for g in qtile.groups if g.name != SCRATCHPAD])

    if current_group:
        group_args = ["-c", current_group]
    else:
        group_args = []

    if current_screen:
        screen_args = ["-W", str(current_screen.dwidth),
                       "-H", str(current_screen.dheight)]
    else:
        screen_args = []

    # logger.warning(json.dumps(grid))
    with open("/tmp/args.json", "w") as f:
        f.write(json.dumps(grid))
    Popen(["qtile_show_groups.py", "-g", json.dumps(grid)] +
          group_args + screen_args)


def signal_group_changed(name=None):
    if name:
        show_groups_grid(qtile, name)
        notify.notify(name, app="Group", tag="GROUP")

    try:
        with open("/tmp/current_workspace_signaler_pid.txt", "r") as f:
            os.kill(int(f.read()), signal.SIGUSR1)
    except FileNotFoundError:
        pass


@ hook.subscribe.changegroup
def group_changed():
    try:
        signal_group_changed(qtile.current_group.name)
    except AttributeError:
        pass


@ hook.subscribe.setgroup
def group_set():
    signal_group_changed(qtile.current_group.name)


@ hook.subscribe.addgroup
def group_added(group):
    signal_group_changed(group)


@ hook.subscribe.delgroup
def group_deleted(group):
    if len(qtile.groups) == 0:
        new_group(qtile)
    signal_group_changed()


@ hook.subscribe.client_new
def floating_dialogs(window):
    dialog = window.window.get_wm_type() == 'dialog'
    transient = window.window.get_wm_transient_for()
    if dialog or transient:
        window.floating = True


# TODO:
# - key binding for moving window to group quickly (CTRL+SUPER+SHIFT + direction)
# - key binding for moving window to screen quickly
# - fix window switcher

keys = [
    #
    # Window control
    #

    # Switch between windows
    Key([SUPER], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([SUPER], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([SUPER], "j", lazy.layout.down(), desc="Move focus down"),
    Key([SUPER], "k", lazy.layout.up(), desc="Move focus up"),
    Key([SUPER], "n", lazy.layout.down(), desc="Move focus down"),
    Key([SUPER], "p", lazy.layout.up(), desc="Move focus up"),
    Key([SUPER], "d", lazy.layout.toggle_split()),

    # Move windows
    Key([SUPER], "Left", lazy.layout.shuffle_left(),
        desc="Move window to the left"),
    Key([SUPER], "Right", lazy.layout.shuffle_right(),
        desc="Move window to the right"),
    Key([SUPER], "Down", lazy.layout.shuffle_down(),
        desc="Move window down"),
    Key([SUPER], "Up", lazy.layout.shuffle_up(), desc="Move window up"),
    Key([SUPER, SHIFT], "h", lazy.layout.shuffle_left(),
        desc="Move window to the left"),
    Key([SUPER, SHIFT], "l", lazy.layout.shuffle_right(),
        desc="Move window to the right"),
    Key([SUPER, SHIFT], "j", lazy.layout.shuffle_down(),
        desc="Move window down"),
    Key([SUPER, SHIFT], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows
    Key([SUPER, ALT], "h", lazy.layout.grow_left().when(
        when_floating=False), desc="Grow window to the left"),
    Key([SUPER, ALT], "l", lazy.layout.grow_right(),
        desc="Grow window to the right"),
    Key([SUPER, ALT], "j", lazy.layout.grow_down(),
        desc="Grow window down"),
    Key([SUPER, ALT], "k", lazy.layout.grow_up(), desc="Grow window up"),

    #
    # Group control
    #

    Key([SUPER, CONTROL], "p", lazy.screen.prev_group()),
    Key([SUPER, CONTROL], "n", lazy.screen.next_group()),
    Key([SUPER, CONTROL], "m", lazy.function(show_groups_grid)),
    Key([SUPER, CONTROL], "l", switch_to_next_group_in_grid(1, 0)),
    Key([SUPER, CONTROL], "h", switch_to_next_group_in_grid(-1, 0)),
    Key([SUPER, CONTROL], "j", switch_to_next_group_in_grid(0, +1)),
    Key([SUPER, CONTROL], "k", switch_to_next_group_in_grid(0, -1)),
    Key([SUPER, CONTROL, SHIFT], "l", move_window_to_next_group_in_grid(1, 0)),
    Key([SUPER, CONTROL, SHIFT], "h", move_window_to_next_group_in_grid(-1, 0)),
    Key([SUPER, CONTROL, SHIFT], "j", move_window_to_next_group_in_grid(0, +1)),
    Key([SUPER, CONTROL, SHIFT], "k", move_window_to_next_group_in_grid(0, -1)),
    Key([SUPER, CONTROL], "bracketright", lazy.next_screen()),
    Key([SUPER, CONTROL], "bracketleft", lazy.prev_screen()),
    Key([SUPER, CONTROL], "c", lazy.function(new_group)),
    Key([SUPER, CONTROL], "q", lazy.function(delete_group)),
    Key([SUPER, CONTROL], "z", lazy.screen.toggle_group()),
    Key([SUPER, CONTROL], "s", lazy.spawn(
        "rofi -modi dswitch:\"qtile_rofi.py --desktops\" -show dswitch -kb-row-down \"Super+Control+s,Down\" -kb-row-up \"Super+Control+Shift+s,Up\" -theme purple"), desc="Search specific group by name"),
    Key([SUPER, SHIFT, CONTROL], "s", lazy.spawn(
        "rofi -modi dswitch:\"qtile_rofi.py --send-to-desktop\" -show dswitch -kb-row-down \"Super+Control+s,Down\" -kb-row-up \"Super+Control+Shift+s,Up\" -theme purple"), desc="Send window to group"),

    # Scratchpad
    Key([SUPER, CONTROL], 't', lazy.group[SCRATCHPAD].dropdown_toggle('term')),
    Key([SUPER, CONTROL], 'w', lazy.group[SCRATCHPAD].dropdown_toggle('web')),
    Key([SUPER, CONTROL], 'e', lazy.group[SCRATCHPAD].dropdown_toggle('notes')),

    # Floating
    Key([SUPER], "f", lazy.window.toggle_floating(),
        desc="Toggle floating fo focused window"),

    #
    # General commands
    #

    Key([SUPER], "e", lazy.layout.normalize()),
    Key([SUPER], "s", lazy.layout.toggle_split()),
    Key([SUPER], "i", lazy.function(toggle_gap)),
    Key([SUPER], "t", lazy.spawn(terminal), desc="Launch terminal"),

    # Run/kill processes
    Key([SUPER], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([SUPER], "o", lazy.spawn("rofi -show file-browser -theme purple")),
    Key([SUPER], "Return", lazy.spawn("rofi -show run -theme purple")),
    Key([SUPER], "s", lazy.spawn(
        "rofi -show windowcd -kb-row-down \"Super+s,Down\" -kb-row-up \"Super+Shift+s,Up\" -theme purple")),
    Key([SUPER, "shift"], "s", lazy.spawn(
        "rofi -show window -kb-row-down \"Super+s,Down\" -kb-row-up \"Super+Shift+s,Up\" -theme purple")),
    # Key([SUPER], "Tab", lazy.spawn("rofi -modi dswitch:\"qtile_rofi.py --desktops\" -show dswitch -theme purple")),
    Key([SUPER], "Return", lazy.spawn("rofi -show run -theme purple"),
        desc="Spawn a command using rofi"),
    Key([SUPER, ALT], "Return", lazy.spawn("rofi -show drun -theme purple"),
        desc="Run an application using rofi"),
    Key([SUPER, SHIFT], "Return", lazy.spawn("rofi -show filebrowser -theme purple"),
        desc="Search a file using rofi"),

    # TODO: see https://github.com/qtile/qtile/pull/3664
    # Key([SUPER, "ALT"], "h", resize_floating_window(width=-10), desc='increase width by 10'),
    # Key([SUPER, "ALT"], "l", resize_floating_window(width=10), desc='decrease width by 10'),
    # Key([SUPER, "ALT"], "k", resize_floating_window(height=-10), desc='increase height by 10'),
    # Key([SUPER, "ALT"], "j", resize_floating_window(height=10), desc='decrease height by 10'),

    # Key([SUPER, CONTROL], "h", move_floating_window(x=-10), desc='increase width by 10'),
    # Key([SUPER, CONTROL], "l", move_floating_window(x=10), desc='decrease width by 10'),
    # Key([SUPER, CONTROL], "k", move_floating_window(y=-10), desc='increase height by 10'),
    # Key([SUPER, CONTROL], "j", move_floating_window(y=10), desc='decrease height by 10'),

    # Brightness and volume control
    Key([], "XF86MonBrightnessDown", lazy.function(
        lambda _: brightness.modify(-4)), desc="Decrease brightness"),
    Key([], "XF86MonBrightnessUp", lazy.function(
        lambda _:brightness.modify(+4)), desc="Increase brightness"),
    Key([], "XF86AudioLowerVolume", lazy.function(
        lambda _: volume.modify(-4)), desc="Decrease volume"),
    Key([], "XF86AudioRaiseVolume", lazy.function(
        lambda _:volume.modify(+4)), desc="Increase volume"),
    Key([], "XF86AudioMute", lazy.function(
        lambda _:volume.toggle()), desc="Toggle volume"),

    Key([SUPER], "grave", lazy.spawn(
        "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")),
]


groups = [
    ScratchPad(SCRATCHPAD,
               [
                   DropDown("term", terminal, opacity=0.8, x=0.05, y=0.01,
                            width=.9, height=0.9, on_focus_lost_hide=True),
                   DropDown("web", "firefox", x=0.025, y=0.01, width=.95,
                            height=.98, on_focus_lost_hide=False),
                   DropDown("notes", "leafpad /tmp/notes.md",
                            x=.2, y=.01, width=.6, height=.5)
               ], single=False),
    Group(NAMES[0], persist=True),
]


layouts = [
    layout.Columns(border_focus=BORDER_COLOR, border_focus_stack=BORDER_COLOR,
                   border_width=1, split=False, margin=MARGIN, border_on_single=True, num_columns=1),
]


widget_defaults = dict(
    font='sans',
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()


screens = [
    Screen(
        top=bar.Gap(32),
        right=bar.Gap(0)
    ),
    Screen(
        top=bar.Gap(32),
        right=bar.Gap(0)
    ),
]


# Drag floating layouts.
mouse = [
    Drag([SUPER], "Button1", move_snap_window(
        snap_dist=50), start=lazy.window.get_position()),
    Drag([SUPER], "Button3", lazy.window.set_size_floating().when(when_floating=True),
         start=lazy.window.get_size()),
    Click([SUPER], "Button2", lazy.window.bring_to_front())
]


dgroups_key_binder = None
dgroups_app_rules = []  # type: List
follow_mouse_focus = True
bring_front_click = False
cursor_warp = True
floating_layout = layout.Floating(
    border_focus=BORDER_COLOR,
    border_width=1,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class='gnome-calculator'),  # calculator
        Match(wm_class='confirmreset'),  # gitk
        Match(wm_class='makebranch'),  # gitk
        Match(wm_class='maketag'),  # gitk
        Match(wm_class='ssh-askpass'),  # ssh-askpass
        # Match(wm_class='Conky'),  # Cony
        Match(title='branchdialog'),  # gitk
        Match(title='pinentry'),  # GPG key password entry
        Match(title="Confirm File Replacing"),
    ])
auto_fullscreen = True
focus_on_window_activation = "focus"  # "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
