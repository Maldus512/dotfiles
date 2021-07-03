#!/usr/bin/env sh
#echo "$1 $2 $3" > /tmp/test
tmux resize-pane -Z -t $1:$2.top
tmux list-panes -t $1:$2 -F '#F' | grep -q Z || tmux select-pane -t $1:$2.bottom
#vedi if-shell
