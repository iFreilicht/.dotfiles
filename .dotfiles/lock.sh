#!/bin/bash

action=${1}
lockname=${2:-default}
lockpath=/tmp/$lockname.lock

case "$action" in
set)
    touch $lockpath
    ;; 
free)
    rm $lockpath
    ;;
wait)
    while [ -f $lockpath ]; do :; done
    ;;
*)
    echo "Usage: $0 <free|set|wait> [lockname]"
    ;;
esac
