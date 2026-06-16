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
    # キャッシュキーに node バイナリのパスを使う
    # command -v はシェル組み込みで subprocess を生まず、
    # mise など version manager ではバージョンごとにパスが変わるため検証キーとして機能する
    local current_node_path
    current_node_path=$(command -v node 2>/dev/null) || return

    # キャッシュが有効ならそのまま返す（1行目: node バイナリパス、2行目: snoretoast パス）
    if [ -f "$SNORETOAST_CACHE" ]; then
        local cached_node_path cached_path
        { IFS= read -r cached_node_path; IFS= read -r cached_path; } < "$SNORETOAST_CACHE"
        if [ "$cached_node_path" = "$current_node_path" ] && [ -n "$cached_path" ] && [ -f "$cached_path" ]; then
            echo "$cached_path"
            return
        fi
    fi

    local exe=""
    if [ "$OS_ENV" = "wsl" ]; then
        # WSL: cmd.exe 経由で Windows 側の npm root を取得し C:\... パスを得る
        # WSL 側の node を使うと snoretoast.exe が UNC パスになり実行不可のため
        local win_npm_root
        win_npm_root=$(cmd.exe /c "npm root -g" 2>/dev/null | tr -d '\r\n')
        if [ -n "$win_npm_root" ]; then
            local wsl_npm_root
            wsl_npm_root=$(wslpath "$win_npm_root" 2>/dev/null)
            exe="${wsl_npm_root}/node-notifier/vendor/snoreToast/snoretoast-x64.exe"
        fi
    else
        local npm_root
        npm_root=$(npm root -g 2>/dev/null) || return
        exe="${npm_root}/node-notifier/vendor/snoreToast/snoretoast-x64.exe"
    fi

    if [ -n "$exe" ] && [ -f "$exe" ]; then
        printf '%s\n%s\n' "$current_node_path" "$exe" > "$SNORETOAST_CACHE"
        echo "$exe"
    else
        # 見つからなかった場合は空ファイルを書いてキャッシュとする
        : > "$SNORETOAST_CACHE"
    fi
}

case "$OS_ENV" in
    wsl)
        SNORETOAST=$(_find_snoretoast)
        if [ -n "$SNORETOAST" ]; then
            WIN_ICON=$(wslpath -w "$ICON")
            "$SNORETOAST" -t "$TITLE" -m "$MESSAGE" -p "$WIN_ICON" || true
        else
            WIN_PS1=$(wslpath -w "$SCRIPT_DIR/notify.ps1")
            WIN_ICON=$(wslpath -w "$ICON")
            powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$WIN_PS1" -Title "$TITLE" -Message "$MESSAGE" -Icon "$WIN_ICON"
        fi
        ;;
    windows)
        SNORETOAST=$(_find_snoretoast)
        if [ -n "$SNORETOAST" ]; then
            WIN_ICON=$(echo "$ICON" | sed 's|^/\([a-zA-Z]\)/|\1:/|')
            "$SNORETOAST" -t "$TITLE" -m "$MESSAGE" -p "$WIN_ICON" || true
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
