#!/usr/bin/env bash

################################################################################
# Select one of the tabs in a tabbed(1) window.
set -e
set -u

################################################################################
if [ $# -ne 1 ]; then
  echo "Usage: $0 tabbed-window-id"
  exit 1
else
  window=$1
fi

################################################################################
list_children_of() {
  parent=$1

  readarray -t ids < <(
    xwininfo -children -id "$parent" |
      awk '/^[[:blank:]]+0x/ { print $1 }'
  )

  for id in "${ids[@]}"; do
    title=$(xdotool getwindowname "$id" | sed 's/[^[:alnum:]]+/_/g')
    printf '["%s (%s)"]="%s"\n' "$title" "$id" "$id"
  done
}

################################################################################
declare -A children="( $(list_children_of "$window") )"

answer=$(rofi -dmenu -i -p "tab" -no-custom < <(
  for title in "${!children[@]}"; do
    echo "$title"
  done
))

id=${children["$answer"]}

if [ -n "$id" ]; then
  xprop -id "$window" \
    -f _TABBED_SELECT_TAB 8s \
    -set _TABBED_SELECT_TAB "$id"
fi
