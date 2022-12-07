#!/usr/bin/env bash

################################################################################
notify() {
  notify-send \
    --expire-time=1000 \
    --app-name=rofi \
    --icon=dialog-password \
    "Password" "$@"
}

################################################################################
show_fields() {
  local password=$1

  while IFS=$'\n' read -r field; do
    echo -en "$field\0icon\x1fsecurity-high\n"
  done < <(
    pass show "$password" |
      tail --lines=+3 |
      sed -e 's/:.*//g' -e '/^ *$/q'
  )
}

################################################################################
copy_field() {
  local password=$1
  local field=$2

  pass show "$password" |
    awk --assign field="$field" \
      --field-separator ': ' \
      '$1 == field {print $2}' |
    xclip -in -selection clipboard -rmlastnl

  notify "Copied $field from $(basename "$password")"
}

################################################################################
if [ -z "${ROFI_PASSWORD_FILE:-}" ]; then
  exit 1
fi

if [ $# -eq 0 ]; then
  show_fields "$ROFI_PASSWORD_FILE"
else
  coproc copy_field "$ROFI_PASSWORD_FILE" "$1" >/dev/null 2>&1
fi
