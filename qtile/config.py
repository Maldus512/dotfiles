from typing import List  # noqa: F401

import libqtile
from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile import hook

import os
import signal
from subprocess import Popen
import random
import environment


mod = "mod4"
terminal = guess_terminal()
NAMES = ["Maxwell", "Iris", "Kate", "Julia", "Sherlock", "Mycroft", "Morland", "Landell", "Livya", "Katia", "Daneel", "Giskard", "Isaac", "Raven", "Isador", "Bert", "Navori"]


def toggle_gap(qtile):
    if qtile.screens[0].right.size == 272:
        qtile.screens[0].right.size = 0
    else:
        qtile.screens[0].right.size = 272


def new_group(qtile):
    counter = 0
    new_name = ""

    while counter < len(NAMES)*2:
        new_name = random.choice(NAMES)
        if not (new_name in [x.name for x in qtile.groups]):
            break
        else:
           counter += 1

    if new_name in [x.name for x in qtile.groups]:
        new_name = new_name + "'"

    qtile.add_group(new_name)
    qtile.current_screen.set_group(qtile.groups[-1])


def delete_group(qtile):
    qtile.delete_group(qtile.current_screen.group.name)


@lazy.function
def resize_floating_window(qtile, width: int = 0, height: int = 0):
    w = qtile.current_window
    w.cmd_set_size_floating(w.width + width, w.height + height)


@hook.subscribe.startup_once
def autostart():
    for cmd in environment.AUTOSTART_LIST:
        Popen(cmd)


def signal_group_changed():
    with open("/tmp/current_workspace_signaler_pid.txt", "r") as f:
        os.kill(int(f.read()), signal.SIGUSR1)


@hook.subscribe.changegroup
def group_changed():
    signal_group_changed()


@hook.subscribe.addgroup
def group_added(group):
    signal_group_changed()


@hook.subscribe.delgroup
def group_deleted(group):
    signal_group_changed()


keys = [
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "n", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "p", lazy.layout.up(), desc="Move focus up"),

    Key([mod], "s", lazy.layout.toggle_split()),

    Key([mod, "control"], "p", lazy.screen.prev_group()),
    Key([mod, "control"], "n", lazy.screen.next_group()),
    Key([mod, "control"], "c", lazy.function(new_group)),
    Key([mod, "control"], "q", lazy.function(delete_group)),
    Key([mod], "z", lazy.screen.togglegroup()),

    Key([mod], "f", lazy.window.toggle_floating(), desc="Toggle floating fo focused window"),

    Key([mod, "mod1"], "h", resize_floating_window(width=10), desc='increase width by 10'),
    Key([mod, "mod1"], "l", resize_floating_window(width=-10), desc='decrease width by 10'),
    Key([mod, "mod1"], "k", resize_floating_window(height=10), desc='increase height by 10'),
    Key([mod, "mod1"], "j", resize_floating_window(height=-10), desc='decrease height by 10'),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod], "Left", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod], "Right", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod], "Down", lazy.layout.shuffle_down(),
        desc="Move window down"),
    Key([mod], "Up", lazy.layout.shuffle_up(), desc="Move window up"),
    Key([mod, "control"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "control"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "control"], "j", lazy.layout.shuffle_down(),
        desc="Move window down"),
    Key([mod, "control"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "mod1"], "h", lazy.layout.grow_left(),
        desc="Grow window to the left"),
    Key([mod, "mod1"], "l", lazy.layout.grow_right(),
        desc="Grow window to the right"),
    Key([mod, "mod1"], "j", lazy.layout.grow_down(),
        desc="Grow window down"),
    Key([mod, "mod1"], "k", lazy.layout.grow_up(), desc="Grow window up"),

    Key([mod], "e", lazy.layout.normalize()),
    Key([mod], "s", lazy.layout.toggle_split()),

    Key([mod], "m", lazy.next_layout()),

    Key([mod], "i", lazy.function(toggle_gap)),

    Key([mod], "t", lazy.spawn(terminal), desc="Launch terminal"),

    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),

    Key([mod], "Return", lazy.spawn("rofi -show run -theme purple")),
    Key(["mod1"], "Tab", lazy.spawn("rofi -show windowcd -theme purple")),
    Key(["mod1", "shift"], "Tab", lazy.spawn("rofi -show window -theme purple")),
    Key([mod], "Tab", lazy.spawn("rofi -modi dswitch:\"qtile_rofi.py --desktops\" -show dswitch -theme purple")),
    Key([mod], "Return", lazy.spawn("rofi -show run -theme purple"),
        desc="Spawn a command using rofi"),
    Key([mod, "mod1"], "Return", lazy.spawn("rofi -show drun -theme purple"),
        desc="Run an application using rofi"),
    Key([mod, "shift"], "Return", lazy.spawn("rofi -show filebrowser -theme purple"),
        desc="Search a file using rofi"),

    Key([mod, "shift"], 't', lazy.group['~/'].dropdown_toggle('term')),
    Key([mod, "shift"], 'w', lazy.group['~/'].dropdown_toggle('web')),
]


MARGIN = [4, 4, 4, 4]
BORDER_COLOR = "#46E600"

groups = [
        ScratchPad("~/", [DropDown("term", terminal, opacity=0.8, x=0.1, y=0.01, width=0.8, height=0.5), DropDown("web", "firefox", x=0, y=0, width=1, height=1)]), 
        Group(random.choice(NAMES))
        ]


layouts = [
    layout.Columns(border_focus=BORDER_COLOR, border_focus_stack=BORDER_COLOR, border_width=2, split=False, margin=MARGIN, border_on_single=True, num_columns=1),
    layout.Max(margin=MARGIN, border_width=2),
]

widget_defaults = dict(
    font='sans',
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top = bar.Gap(32),
        right = bar.Gap(0)
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating().when(when_floating=True),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating().when(when_floating=True),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    border_focus=BORDER_COLOR,
    border_width=2,
    float_rules=[
    # Run the utility of `xprop` to see the wm class and name of an X client.
    *layout.Floating.default_float_rules,
    Match(wm_class='confirmreset'),  # gitk
    Match(wm_class='makebranch'),  # gitk
    Match(wm_class='maketag'),  # gitk
    Match(wm_class='ssh-askpass'),  # ssh-askpass
    Match(title='branchdialog'),  # gitk
    Match(title='pinentry'),  # GPG key password entry
    Match(wm_class='Conky')
])
auto_fullscreen = True
focus_on_window_activation = "smart"
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
