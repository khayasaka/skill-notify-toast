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

# node-notifier に同梱された snoretoast.exe を探す
# パスをキャッシュして2回目以降の npm 起動コストを排除する
SNORETOAST_CACHE="$(dirname "$SCRIPT_DIR")/.snoretoast_cache"
_find_snoretoast() {
    # キャッシュが有効ならそのまま返す
    if [ -f "$SNORETOAST_CACHE" ]; then
        local cached
        cached=$(cat "$SNORETOAST_CACHE")
        if [ -n "$cached" ] && [ -f "$cached" ]; then
            echo "$cached"
            return
        fi
    fi
    # キャッシュがない場合は npm で探してキャッシュに書く
    local npm_root
    npm_root=$(npm root -g 2>/dev/null) || return
    local exe="${npm_root}/node-notifier/vendor/snoreToast/snoretoast-x64.exe"
    if [ -f "$exe" ]; then
        echo "$exe" > "$SNORETOAST_CACHE"
        echo "$exe"
    else
        # 見つからなかった場合は空ファイルを書いてキャッシュとする
        : > "$SNORETOAST_CACHE"
    fi
}

case "$OS_ENV" in
    wsl)
        SNORETOAST=$(_find_snoretoast)
        # WSL 側 Linux ファイルシステム上の EXE は UNC パス（\\wsl.localhost\...）になり
        # Windows のセキュリティポリシーで実行がブロックされる場合があるため
        # Windows ドライブにマウントされた /mnt/ 配下のみ snoretoast を使用する
        if [ -n "$SNORETOAST" ] && [[ "$SNORETOAST" == /mnt/* ]]; then
            WIN_SNORETOAST=$(wslpath -w "$SNORETOAST")
            powershell.exe -NoProfile -NonInteractive -Command "Start-Process '$WIN_SNORETOAST' -ArgumentList '-t','$TITLE','-m','$MESSAGE' -NoNewWindow"
        else
            WIN_PS1=$(wslpath -w "$SCRIPT_DIR/notify.ps1")
            WIN_ICON=$(wslpath -w "$ICON")
            powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$WIN_PS1" -Title "$TITLE" -Message "$MESSAGE" -Icon "$WIN_ICON"
        fi
        ;;
    windows)
        SNORETOAST=$(_find_snoretoast)
        if [ -n "$SNORETOAST" ]; then
            powershell -NoProfile -NonInteractive -Command "Start-Process '$SNORETOAST' -ArgumentList '-t','$TITLE','-m','$MESSAGE' -NoNewWindow"
        else
            WIN_PS1=$(echo "$SCRIPT_DIR/notify.ps1" | sed 's|^/\([a-zA-Z]\)/|\1:/|')
            WIN_ICON=$(echo "$ICON" | sed 's|^/\([a-zA-Z]\)/|\1:/|')
            powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$WIN_PS1" -Title "$TITLE" -Message "$MESSAGE" -Icon "$WIN_ICON"
        fi
        ;;
    macos|linux)
        bash "$SCRIPT_DIR/notify.sh" "$TITLE" "$MESSAGE" "$ICON"
        ;;
esac
