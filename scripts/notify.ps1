# Windows / WSL / Git Bash only
# Usage: powershell -ExecutionPolicy Bypass -File notify.ps1 -Title "title" -Message "message" [-Icon "C:\path\to\icon.png"]
# From WSL: powershell.exe -ExecutionPolicy Bypass -File (wslpath -w $SCRIPT) -Title "..." -Message "..." -Icon (wslpath -w $ICON)
param(
    [string]$Title = "Notification",
    [string]$Message = "Done",
    [string]$Icon = ""
)

# Auto-install BurntToast if not present
if (-not (Get-Module -ListAvailable -Name BurntToast)) {
    if (Get-Command Install-PSResource -ErrorAction SilentlyContinue) {
        Install-PSResource -Name BurntToast -Scope CurrentUser -TrustRepository
    } else {
        Install-Module -Name BurntToast -Scope CurrentUser -Force
    }
}

Import-Module BurntToast

if ($Icon -and (Test-Path $Icon)) {
    New-BurntToastNotification -Text $Title, $Message -AppLogo $Icon
} else {
    New-BurntToastNotification -Text $Title, $Message
}
