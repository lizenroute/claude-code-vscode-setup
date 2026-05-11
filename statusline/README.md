# Statusline for Claude Code

A two-line status bar for Claude Code (VS Code extension).

```
🍕 ~/…/my-project  |  🐼 main  |  5h ████░░░░ 42%  ↺ 14:30  |  7d █████░░░ 61%
🤖 Claude Sonnet 4.6  |  🎨 23%  +45  -12  |  TPE 21:34
```

**Line 1** — project folder, git branch, rate limit bars (5h / 7d) with reset times  
**Line 2** — model name, context window %, lines added/removed, auto timezone (TPE / BKK / GMT±N)

---

## Install

### Windows

```powershell
.\install.ps1
```

Requires: [Node.js](https://nodejs.org)

### Mac / Linux

```bash
bash install.sh
```

Uses Node.js if installed (full version). Falls back to bash if not (minimal: timezone + context %).

---

## Manual install

1. Copy `statusline.js` to `~/.claude/statusline.js`
2. Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "node \"/Users/you/.claude/statusline.js\""
  }
}
```

3. In VS Code: `Ctrl/Cmd+Shift+P` → `Developer: Reload Window`

---

## Color legend

| Color | Meaning |
|-------|---------|
| Green (sage) | Usage below 60% |
| Gold | Usage 60–85% |
| Red (muted) | Usage above 85% |
