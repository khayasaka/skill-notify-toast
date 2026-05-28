#!/usr/bin/env bash
# macOS / Linux only — use notify.ps1 for WSL and Windows
# Usage: notify.sh [title] [message] [icon_path]

TITLE="${1:-Notification}"
MESSAGE="${2:-Done}"
ICON="${3:-}"

case "$(uname -s)" in
    Darwin)
        # osascript does not support custom icons
        osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\""
        ;;
    Linux)
        if command -v notify-send &>/dev/null; then
            if [ -n "$ICON" ] && [ -f "$ICON" ]; then
                notify-send -i "$ICON" "$TITLE" "$MESSAGE"
            else
                notify-send "$TITLE" "$MESSAGE"
            fi
        else
            echo "[notify] $TITLE: $MESSAGE"
            if command -v apt &>/dev/null; then
                echo "notify-send not found. Install it with: sudo apt install libnotify-bin" >&2
            elif command -v dnf &>/dev/null; then
                echo "notify-send not found. Install it with: sudo dnf install libnotify" >&2
            elif command -v pacman &>/dev/null; then
                echo "notify-send not found. Install it with: sudo pacman -S libnotify" >&2
            elif command -v zypper &>/dev/null; then
                echo "notify-send not found. Install it with: sudo zypper install libnotify-tools" >&2
            else
                echo "notify-send not found. Please install libnotify for your distribution." >&2
            fi
        fi
        ;;
esac
