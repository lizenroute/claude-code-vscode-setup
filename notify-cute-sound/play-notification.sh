#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
afplay "$SCRIPT_DIR/notification.mp3" &
osascript -e 'display notification "Done! Your turn :)" with title "Claude Code"' 2>/dev/null || true
