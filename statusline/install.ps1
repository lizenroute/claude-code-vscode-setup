# install.ps1 - Claude Code Statusline 安裝腳本（Windows）
# https://github.com/lizenroute/claude-code-vscode-setup

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== Claude Code Statusline - Windows Installer ===" -ForegroundColor Cyan
Write-Host ""

# Check Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Node.js not found. Install from https://nodejs.org" -ForegroundColor Red
    exit 1
}
$nodeVer = (node --version 2>&1)
Write-Host "Node.js: $nodeVer" -ForegroundColor Gray

$scriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$claudeDir    = Join-Path $env:USERPROFILE ".claude"
$settingsPath = Join-Path $claudeDir "settings.json"

# Ensure .claude dir exists
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
}

# Copy statusline.js
$destJs = Join-Path $claudeDir "statusline.js"
Copy-Item -Path (Join-Path $scriptDir "statusline.js") -Destination $destJs -Force
Write-Host "Copied: statusline.js -> $destJs" -ForegroundColor Green

# Backup existing settings.json
if (Test-Path $settingsPath) {
    $backup = "$settingsPath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $settingsPath $backup
    Write-Host "Backed up: $backup" -ForegroundColor Yellow
    $settings = Get-Content $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
} else {
    $settings = [PSCustomObject]@{}
}

# Patch statusLine
$statusLineCmd = "node `"$destJs`""
$statusLine = [PSCustomObject]@{ type = "command"; command = $statusLineCmd }
if ($settings.PSObject.Properties["statusLine"]) {
    $settings.statusLine = $statusLine
} else {
    $settings | Add-Member -NotePropertyName "statusLine" -NotePropertyValue $statusLine
}

$settings | ConvertTo-Json -Depth 20 | Set-Content $settingsPath -Encoding UTF8
Write-Host "Updated: $settingsPath" -ForegroundColor Green

Write-Host ""
Write-Host "Done! In VS Code: Ctrl+Shift+P -> 'Developer: Reload Window'" -ForegroundColor Cyan
Write-Host ""
