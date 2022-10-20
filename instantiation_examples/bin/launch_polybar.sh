#!/usr/bin/env sh

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    echo $m
    MONITOR=$m polybar --reload g57 &
  done
else
  polybar --reload g57 &
fi
