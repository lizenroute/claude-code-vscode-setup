#!/bin/bash
# install.sh - Claude Code 通知安裝腳本（Mac）
# https://github.com/lizenroute/claude-code-vscode-setup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_SOUND_DIR="$HOME/.claude/sounds"

echo ""
echo "=== Claude Code Notify - Mac Installer ==="
echo ""

# --- 步驟 1：選擇音效存放路徑 ---
echo "Where do you want to store the sound file?"
echo "  [1] Default: $DEFAULT_SOUND_DIR  (recommended)"
echo "  [2] Custom path"
echo ""
read -r -p "Enter 1 or 2 (press Enter for default): " choice

if [ "$choice" = "2" ]; then
    read -r -p "Enter full folder path: " SOUND_DIR
else
    SOUND_DIR="$DEFAULT_SOUND_DIR"
fi

# --- 步驟 2：選擇音效檔案 ---
echo ""
echo "Which notification sound do you want to use?"
echo "  [1] Default sound (bundled notification.mp3)"
echo "  [2] My own MP3 file"
echo ""
read -r -p "Enter 1 or 2 (press Enter for default): " choice2

if [ "$choice2" = "2" ]; then
    read -r -p "Enter full path to your MP3 file: " CUSTOM_MP3
    if [ -f "$CUSTOM_MP3" ]; then
        MP3_SOURCE="$CUSTOM_MP3"
    else
        echo "File not found, falling back to default sound."
        MP3_SOURCE="$SCRIPT_DIR/notification.mp3"
    fi
else
    MP3_SOURCE="$SCRIPT_DIR/notification.mp3"
fi

# --- 步驟 3：建立資料夾、複製檔案 ---
mkdir -p "$SOUND_DIR"
cp "$MP3_SOURCE" "$SOUND_DIR/notification.mp3"
cp "$SCRIPT_DIR/play-notification.sh" "$SOUND_DIR/play-notification.sh"
chmod +x "$SOUND_DIR/play-notification.sh"
echo "Copied files to: $SOUND_DIR"

# --- 步驟 4：更新 ~/.claude/settings.json ---
SETTINGS_DIR="$HOME/.claude"
SETTINGS_PATH="$SETTINGS_DIR/settings.json"
SCRIPT_DEST="$SOUND_DIR/play-notification.sh"

mkdir -p "$SETTINGS_DIR"

python3 - <<PYEOF
import json, os, sys

settings_path = "$SETTINGS_PATH"
script_dest   = "$SCRIPT_DEST"
hook_command  = 'bash "' + script_dest + '"'

if os.path.exists(settings_path):
    with open(settings_path, "r", encoding="utf-8") as f:
        settings = json.load(f)
else:
    settings = {}

settings.setdefault("hooks", {}).setdefault("Stop", [])

already = any(
    any(h.get("command", "") == hook_command for h in (g.get("hooks") or []))
    for g in settings["hooks"]["Stop"]
)

if not already:
    settings["hooks"]["Stop"].append({
        "hooks": [{
            "type":    "command",
            "command": hook_command,
            "async":   True
        }]
    })

with open(settings_path, "w", encoding="utf-8") as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)

print("Updated: " + settings_path)
PYEOF

echo ""
echo "Installation complete!"
echo "Claude Code will play a sound and show a notification when it finishes a response."
echo "To disable: open Claude Code and run /hooks"
echo ""
