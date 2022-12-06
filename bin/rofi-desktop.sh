#!/usr/bin/env bash

set -e
set -u

if [ $# -eq 0 ]; then
  # Rofi wants a list of desktops:
  declare -a desktops
  mapfile -t desktops < <(
    wmctrl -d |
      awk '{
        for (i=($8 == "N/A" ? 9 : 10); i<=NF; i++) {
          printf("%s:%d%s", $i, $1 + 1, i<NF ? OFS : "\n")
        }
      }'
  )

  for d in "${desktops[@]}"; do
    echo -en "$d\0icon\x1fdesktop\n"
  done
else
  desktop_id=$(echo "$1" | cut -d: -f2)
  [ -z "$desktop_id" ] && exit
  wmctrl -s "$((desktop_id - 1))"
fi
