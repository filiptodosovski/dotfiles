#!/bin/sh
# Keep date/percentage escapes out of tmux's own strftime formatter.
if command -v pmset >/dev/null 2>&1; then
  battery=$(pmset -g batt | sed -nE 's/.*[[:space:]]([0-9]+)%.*/\1%/p')
  [ -z "$battery" ] || printf '󰁹 %s │ ' "$battery"
fi
printf '󰃭 %s │ 󰥔 %s' "$(LC_ALL=C date '+%a %b %d' | tr '[:lower:]' '[:upper:]')" "$(date '+%H:%M')"
