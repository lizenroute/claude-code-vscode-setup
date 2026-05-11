#!/bin/bash
# install.sh - Claude Code Statusline 安裝腳本（Mac / Linux）
# https://github.com/lizenroute/claude-code-vscode-setup

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo ""
echo "=== Claude Code Statusline - Mac/Linux Installer ==="
echo ""

mkdir -p "$CLAUDE_DIR"

# Choose node or bash mode
if command -v node >/dev/null 2>&1; then
    MODE="node"
    cp "$SCRIPT_DIR/statusline.js" "$CLAUDE_DIR/statusline.js"
    echo "✓ Node.js $(node --version) found — full statusline installed"
else
    MODE="bash"
    cp "$SCRIPT_DIR/statusline.sh" "$CLAUDE_DIR/statusline.sh"
    chmod +x "$CLAUDE_DIR/statusline.sh"
    echo "⚠ Node.js not found — minimal bash statusline installed"
    echo "  Install Node.js for the full experience: https://nodejs.org"
fi

# Backup settings if exists
if [ -f "$SETTINGS_FILE" ]; then
    BACKUP="${SETTINGS_FILE}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$SETTINGS_FILE" "$BACKUP"
    echo "Backed up: $BACKUP"
fi

# Patch settings.json via Python (available on all macOS/Linux)
MODE="$MODE" CLAUDE_DIR="$CLAUDE_DIR" python3 - <<'PYEOF'
import json, os

mode       = os.environ["MODE"]
claude_dir = os.environ["CLAUDE_DIR"]
settings_file = os.path.join(claude_dir, "settings.json")

if mode == "node":
    cmd = f'node "{os.path.join(claude_dir, "statusline.js")}"'
else:
    cmd = f'bash "{os.path.join(claude_dir, "statusline.sh")}"'

settings = {}
if os.path.exists(settings_file):
    with open(settings_file, "r", encoding="utf-8") as f:
        settings = json.load(f)

settings["statusLine"] = {"type": "command", "command": cmd}

with open(settings_file, "w", encoding="utf-8") as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)

print(f"Updated: {settings_file}")
PYEOF

echo ""
echo "Done! In VS Code: Cmd+Shift+P -> 'Developer: Reload Window'"
echo ""
