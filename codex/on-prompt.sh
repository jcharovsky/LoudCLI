#!/bin/bash
# Save timestamp and schedule Start sound after 10s delay.

TS=$(date +%s)
TS_FILE="/tmp/loudcli-codex-task.ts"
echo "$TS" > "$TS_FILE"
(sleep 10 && [ -f "$TS_FILE" ] && [ "$(cat "$TS_FILE")" = "$TS" ] && afplay ~/.codex/hooks/sounds/GLaDOS/Start-2.aiff) >/dev/null 2>&1 &
