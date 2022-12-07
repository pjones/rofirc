#!/usr/bin/env bash

exec rofi \
  -config "@out@/etc/config.rasi" \
  -theme "@out@/themes/launcher.rasi" \
  "$@"
