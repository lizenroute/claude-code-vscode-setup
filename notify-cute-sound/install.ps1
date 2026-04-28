# install.ps1 - Claude Code 通知安裝腳本（Windows）
# https://github.com/lizenroute/claude-code-vscode-setup

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== Claude Code Notify - Windows Installer ===" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# --- 步驟 1：選擇音效存放路徑 ---
$defaultSoundDir = Join-Path $env:USERPROFILE ".claude\sounds"
Write-Host "Where do you want to store the sound file?"
Write-Host "  [1] Default: $defaultSoundDir  (recommended)"
Write-Host "  [2] Custom path"
Write-Host ""
$choice = Read-Host "Enter 1 or 2 (press Enter for default)"

if ($choice -eq "2") {
    $soundDir = (Read-Host "Enter full folder path").Trim('"').TrimEnd('\')
} else {
    $soundDir = $defaultSoundDir
}

# --- 步驟 2：選擇音效檔案 ---
Write-Host ""
Write-Host "Which notification sound do you want to use?"
Write-Host "  [1] Default sound (bundled notification.mp3)"
Write-Host "  [2] My own MP3 file"
Write-Host ""
$choice2 = Read-Host "Enter 1 or 2 (press Enter for default)"

if ($choice2 -eq "2") {
    $customMp3 = (Read-Host "Enter full path to your MP3 file").Trim('"')
    if (Test-Path $customMp3) {
        $mp3Source = $customMp3
    } else {
        Write-Host "File not found, falling back to default sound." -ForegroundColor Yellow
        $mp3Source = Join-Path $scriptDir "notification.mp3"
    }
} else {
    $mp3Source = Join-Path $scriptDir "notification.mp3"
}

# --- 步驟 3：建立資料夾、複製檔案 ---
if (-not (Test-Path $soundDir)) {
    New-Item -ItemType Directory -Path $soundDir -Force | Out-Null
    Write-Host "Created folder: $soundDir" -ForegroundColor Green
}

$mp3Dest  = Join-Path $soundDir "notification.mp3"
$ps1Dest  = Join-Path $soundDir "play-notification.ps1"
$ps1Src   = Join-Path $scriptDir "play-notification.ps1"

Copy-Item -Path $mp3Source -Destination $mp3Dest -Force
Copy-Item -Path $ps1Src   -Destination $ps1Dest  -Force
Write-Host "Copied files to: $soundDir" -ForegroundColor Green

# --- 步驟 4：更新 ~/.claude/settings.json ---
$settingsDir  = Join-Path $env:USERPROFILE ".claude"
$settingsPath = Join-Path $settingsDir "settings.json"

if (-not (Test-Path $settingsDir)) {
    New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
}

$settings = if (Test-Path $settingsPath) {
    Get-Content $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
} else {
    [PSCustomObject]@{}
}

$hookCommand = "powershell -NoProfile -STA -WindowStyle Hidden -File `"$ps1Dest`""

# 確保 hooks.Stop 存在
if (-not $settings.PSObject.Properties["hooks"]) {
    $settings | Add-Member -NotePropertyName "hooks" -NotePropertyValue ([PSCustomObject]@{})
}
if (-not $settings.hooks.PSObject.Properties["Stop"]) {
    $settings.hooks | Add-Member -NotePropertyName "Stop" -NotePropertyValue @()
}

# 避免重複加入
$alreadyAdded = @($settings.hooks.Stop) | Where-Object {
    $_.hooks -and ($_.hooks | Where-Object { $_.command -like "*play-notification.ps1*" })
}

if (-not $alreadyAdded) {
    $newEntry = [PSCustomObject]@{
        hooks = @(
            [PSCustomObject]@{
                type    = "command"
                command = $hookCommand
                shell   = "powershell"
                async   = $true
            }
        )
    }
    $settings.hooks | Add-Member -NotePropertyName "Stop" `
        -NotePropertyValue (@($settings.hooks.Stop) + $newEntry) -Force
}

$settings | ConvertTo-Json -Depth 20 | Set-Content $settingsPath -Encoding UTF8
Write-Host "Updated: $settingsPath" -ForegroundColor Green

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Cyan
Write-Host "Claude Code will play a sound and show a notification when it finishes a response."
Write-Host "To disable: open Claude Code and run /hooks"
Write-Host ""
