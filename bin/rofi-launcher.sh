#!/bin/sh

# Wrapper around rofi:
exec rofi-wrapper.sh \
  -show combi \
  -kb-accept-custom "" -kb-custom-1 "Control+Return" \
  "$@"
