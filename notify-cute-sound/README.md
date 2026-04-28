# notify-cute-sound

Claude Code 完成回應、等你輸入時，自動播放提示音並彈出桌面通知。

Plays a cute sound and shows a desktop notification whenever Claude Code finishes a response and is waiting for your input.

---

## 安裝 / Install

### Windows

```powershell
# 在此資料夾下執行
.\install.ps1
```

安裝程式會問你兩個問題：
1. 音效檔要存在哪（預設 `~/.claude/sounds/`）
2. 用預設音效還是自己的 MP3

The installer will ask you two questions:
1. Where to store the sound file (default: `~/.claude/sounds/`)
2. Use the bundled sound or your own MP3

### Mac

```bash
# 先給執行權限
chmod +x install.sh
./install.sh
```

需要 Python 3（macOS 內建）。

Requires Python 3 (built-in on macOS).

---

## 資料夾結構 / File Structure

```
notify-cute-sound/
├── install.ps1            # Windows 安裝腳本
├── install.sh             # Mac 安裝腳本
├── play-notification.ps1  # Windows 通知腳本（安裝時會複製到你的機器）
├── play-notification.sh   # Mac 通知腳本（安裝時會複製到你的機器）
└── notification.mp3       # 預設提示音
```

---

## 移除 / Uninstall

1. 開啟 Claude Code，輸入 `/hooks`，找到 Stop hook 並刪除
2. 刪除 `~/.claude/sounds/` 資料夾（選擇性）

1. Open Claude Code, run `/hooks`, delete the Stop hook entry
2. Delete `~/.claude/sounds/` folder (optional)

---

## 系統需求 / Requirements

| 系統 | 需求 |
|------|------|
| Windows | Windows 10/11、PowerShell 5.1+、Claude Code |
| Mac | macOS 11+、Python 3（內建）、Claude Code |

---

## 自訂音效 / Custom Sound

安裝時選 `[2] My own MP3 file` 並輸入你的 MP3 路徑即可。

During installation, choose `[2] My own MP3 file` and enter your MP3 path.
