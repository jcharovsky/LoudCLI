#!/bin/bash
# Save timestamp and schedule Start sound after 10s delay.
# If Stop fires before 10s, the timestamp file will be removed,
# cancelling the scheduled sound.
TS=$(date +%s)
echo "$TS" > /tmp/claude-sound-ts
(sleep 10 && [ -f /tmp/claude-sound-ts ] && [ "$(cat /tmp/claude-sound-ts)" = "$TS" ] && afplay ~/.claude/hooks/sounds/GLaDOS/Start-2.aiff) &
