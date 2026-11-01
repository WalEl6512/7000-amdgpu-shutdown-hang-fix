#!/bin/bash
# Shutdown diagnostics. Usage: sudo tools/diag-boot.sh on|off
#   on : text console instead of the boot splash, per-device shutdown messages
#        (initcall_debug), and a 2s pause after each hook message. Reboot afterwards.
#   off: restore the normal splash ("rhgb quiet") and turn the pauses off.
[ "$(id -u)" = 0 ] || { echo "Run with sudo: sudo $0 on|off" >&2; exit 1; }
CONF=/etc/amdgpu-power-fix.conf
case "$1" in
  on)  grubby --update-kernel=ALL --remove-args="rhgb quiet" --args="initcall_debug"
       [ -e $CONF ] && sed -i 's/^VERBOSE=.*/VERBOSE=1/' $CONF ;;
  off) grubby --update-kernel=ALL --remove-args="initcall_debug" --args="rhgb quiet"
       [ -e $CONF ] && sed -i 's/^VERBOSE=.*/VERBOSE=0/' $CONF ;;
  *)   echo "usage: $0 on|off" >&2; exit 1 ;;
esac
grubby --info=DEFAULT | grep ^args
