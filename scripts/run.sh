#!/usr/bin/env bash
# Cross-platform notification entry point
# Detects AI tool (for icon) and OS environment, then calls the appropriate script
# Usage: run.sh [title] [message]

TITLE="${1:-Notification}"
MESSAGE="${2:-Done}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$(dirname "$SCRIPT_DIR")/assets"

# Detect AI tool
if [ "${CLAUDECODE:-}" = "1" ]; then
    TOOL="claude"
elif [ "${CURSOR_AGENT:-}" = "1" ]; then
    TOOL="cursor"
else
    TOOL="copilot"
fi

# Detect OS environment
if [ -n "$WSL_DISTRO_NAME" ] || ([ -f "/proc/version" ] && grep -qi microsoft /proc/version 2>/dev/null); then
    OS_ENV="wsl"
elif [ "$(uname -s)" = "Darwin" ]; then
    OS_ENV="macos"
elif [[ "$(uname -s)" == MINGW* ]] || [[ "$(uname -s)" == MSYS* ]] || [ "${OS:-}" = "Windows_NT" ]; then
    OS_ENV="windows"
else
    OS_ENV="linux"
fi

ICON="$ASSETS_DIR/${TOOL}.png"

case "$OS_ENV" in
    wsl)
        WIN_PS1=$(wslpath -w "$SCRIPT_DIR/notify.ps1")
        WIN_ICON=$(wslpath -w "$ICON")
        powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$WIN_PS1" -Title "$TITLE" -Message "$MESSAGE" -Icon "$WIN_ICON"
        ;;
    windows)
        WIN_PS1=$(echo "$SCRIPT_DIR/notify.ps1" | sed 's|^/\([a-zA-Z]\)/|\1:/|')
        WIN_ICON=$(echo "$ICON" | sed 's|^/\([a-zA-Z]\)/|\1:/|')
        powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$WIN_PS1" -Title "$TITLE" -Message "$MESSAGE" -Icon "$WIN_ICON"
        ;;
    macos|linux)
        bash "$SCRIPT_DIR/notify.sh" "$TITLE" "$MESSAGE" "$ICON"
        ;;
esac
