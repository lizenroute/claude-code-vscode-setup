param(
    [string]$Message = "Done! Your turn :)"
)
try {
    Add-Type -AssemblyName presentationCore
    $f = Join-Path $PSScriptRoot "notification.mp3"
    $m = [System.Windows.Media.MediaPlayer]::new()
    $m.Open([uri]("file:///" + $f.Replace('\', '/')))
    $m.Play()
} catch {}
try {
    [Windows.UI.Notifications.ToastNotificationManager,Windows.UI.Notifications,ContentType=WindowsRuntime] | Out-Null
    [Windows.Data.Xml.Dom.XmlDocument,Windows.Data.Xml.Dom.XmlDocument,ContentType=WindowsRuntime] | Out-Null
    $safeMsg = [System.Security.SecurityElement]::Escape($Message)
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml('<toast><visual><binding template="ToastGeneric"><text>Claude Code</text><text>' + $safeMsg + '</text></binding></visual></toast>')
    $toast = New-Object Windows.UI.Notifications.ToastNotification($xml)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('ClaudeCode').Show($toast)
} catch {}
Start-Sleep -Seconds 2
