#!/usr/bin/env bash

################################################################################
# A much simpler version of rofi-pass, a tool to select passwords via
# rofi.  My version only uses the clipboard which works better in my
# experience than auto typing.
#
# Usage:
#
#  * Select a password and press Return to copy it to the clipboard
#
#  * Select a password and press Control+Return to copy a field from
#    the password file instead.

################################################################################
export PASSWORD_STORE_DIR=${PASSWORD_STORE_DIR:-$HOME/.password-store}

################################################################################
_rofi() {
  rofi "$@"
}

################################################################################
_notify() {
  notify-send --expire-time=1000 --app-name=rofi "Password" "$@"
}

################################################################################
show_passwords() {
  find "$PASSWORD_STORE_DIR" -type f -name '*.gpg' -printf '%P\n' |
    sed 's/\.gpg$//' |
    _rofi -dmenu -p "pass" -kb-accept-custom "" -kb-custom-1 "Control+Return"
}

################################################################################
show_fields() {
  local password=$1

  pass show "$password" |
    tail --lines=+3 |
    sed -e 's/:.*//g' -e '/^ *$/q' |
    _rofi -dmenu -p "pass field"
}

################################################################################
select_and_copy_field() {
  local password=$1
  field=$(show_fields "$password")

  if [ -z "$field" ]; then
    exit
  fi

  pass show "$password" |
    grep --fixed-strings "${field}:" |
    awk -F ': ' '{print $2}' |
    xclip -in -selection clipboard -rmlastnl

  _notify "Copied $field from $password"
}

################################################################################
# Here's where things start:
password=$(show_passwords)

case $? in
0)
  pass show --clip "$password"
  _notify "Copied $password"
  ;;

10)
  select_and_copy_field "$password"
  ;;
esac
