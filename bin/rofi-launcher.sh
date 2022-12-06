#!/bin/sh

# Wrapper around rofi:
exec rofi \
  -show combi \
  -config "@out@/etc/config.rasi" \
  -theme "@out@/themes/launcher.rasi" \
  "$@"
