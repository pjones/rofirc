#!/usr/bin/env bash

set -e
set -u

current_window_id=$(xdo id)
current_window_title=$(xdotool getwindowname "$current_window_id")

if [ $# -eq 0 ]; then
  # Rofi wants a list of desktops:
  declare -a desktops
  mapfile -t desktops < <(wmctrl -d | awk '$2 != "*" && $9 != "NSP" { print $1 ":" $9 }')
  echo -en "\0message\x1fOr move \"$current_window_title\" with C-RET\n"

  for d in "${desktops[@]}"; do
    echo -en "$d\0icon\x1fdesktop\n"
  done
else
  desktop_id=$(echo "$1" | cut -d: -f1)
  [ -z "$desktop_id" ] && exit

  # ROFI_RETV is only set in version 1.5.5 or greater.
  case "${ROFI_RETV:-0}" in
  10)
    wmctrl -r "$current_window_id" -t "$desktop_id"
    ;;

  *)
    wmctrl -s "$desktop_id"
    ;;
  esac
fi
