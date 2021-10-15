#!/usr/bin/env sh
 
APPCHK=$(ps aux | grep conky | grep -v "grep conky" | wc -l)
 
if [ "$APPCHK" = '2' ];
then
    conky "$@" &
else
    echo "Conky is already running"
fi
 
exit
