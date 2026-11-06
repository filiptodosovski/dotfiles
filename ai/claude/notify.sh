#!/bin/sh
# Claude Code hooks (async, never block a reply):
#   notify.sh done   Stop: soft chime when the main response finishes.
#   notify.sh input  Notification: different chime plus a banner, because
#                    Claude is waiting for approval or input.
[ "$(uname -s)" = Darwin ] || exit 0
event="${1:-done}"
input="$(cat 2>/dev/null || :)"

if [ "$event" = input ]; then
  sound=Ping
  message="Claude needs your input"
  title="Claude Code"
  if command -v jq >/dev/null 2>&1 && [ -n "$input" ]; then
    message="$(printf '%s' "$input" | jq -r '.message // empty' 2>/dev/null)" || :
    project="$(printf '%s' "$input" | jq -r '.cwd // empty | split("/") | last' 2>/dev/null)" || :
    [ -n "$message" ] || message="Claude needs your input"
    [ -z "$project" ] || title="Claude Code · $project"
  fi
  # Pass text as arguments so quotes in the message can't break the script.
  /usr/bin/osascript \
    -e 'on run argv' \
    -e 'display notification (item 1 of argv) with title (item 2 of argv)' \
    -e 'end run' "$message" "$title" >/dev/null 2>&1 || :
else
  sound=Glass
fi

[ -x /usr/bin/afplay ] && /usr/bin/afplay -v 0.4 "/System/Library/Sounds/$sound.aiff" >/dev/null 2>&1
exit 0
