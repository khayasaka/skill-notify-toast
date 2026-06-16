[日本語はこちら](README.ja.md)

# notify skill

A cross-platform toast notification skill for Claude Code, GitHub Copilot CLI, and Cursor.

Automatically detects the running AI tool and OS environment, then displays a toast notification with the appropriate icon.

## Supported Environments

| Environment | Notification | Icon |
|-------------|:------------:|:----:|
| Windows (Git Bash) | ✅ | ✅ |
| WSL | ✅ | ✅ |
| macOS | ✅ | — |
| Linux | ✅ | ✅ |

> **macOS**: `osascript` does not support custom icons. The system icon of the terminal app will be shown instead.

## Requirements

| Environment | Requirement |
|-------------|-------------|
| Windows / WSL | [BurntToast](https://github.com/Windos/BurntToast) — auto-installed on first run |
| Windows / WSL (optional) | [node-notifier](https://www.npmjs.com/package/node-notifier) — enables faster notifications via snoretoast |
| Linux | `notify-send` — install via your package manager |
| macOS | None |

### Faster notifications with node-notifier (Windows / WSL)

Installing [node-notifier](https://www.npmjs.com/package/node-notifier) globally enables notifications via [snoretoast](https://github.com/KDE/snoretoast), which is significantly faster than BurntToast because it uses a non-blocking native executable.

```bash
npm install -g node-notifier
```

- The snoretoast path is cached in `.snoretoast_cache` after the first run to avoid npm startup overhead.
- If node-notifier is not installed, the skill falls back to BurntToast automatically.
- **WSL**: snoretoast is looked up from the **Windows-side** npm (via `cmd.exe`), not the WSL-side npm. WSL-side node-notifier is not used because the EXE would resolve to a UNC path (`\\wsl.localhost\...`) which may be blocked by Windows security policy.

## Installation

Clone this repository into your `.claude/skills/` directory:

```bash
git clone https://github.com/khayasaka/skill-notify-toast.git ~/.claude/skills/notify
```

## Icon Setup (Optional)

Place PNG files in the `assets/` directory to show tool-specific icons in notifications.
If no file is found, the notification will appear without an icon.

| Filename | Used by |
|----------|---------|
| `claude.png` | Claude Code |
| `cursor.png` | Cursor |
| `copilot.png` | GitHub Copilot CLI |

Icons are not included in this repository due to licensing restrictions.
You can download them from sources such as [UXWing](https://uxwing.com/) for personal use.

> The `assets/` directory is excluded from version control via `.gitignore`.

## Usage

```
/notify [title] [message]
```

## How It Works

The skill detects the environment in two steps:

**1. AI tool detection**

| Environment Variable | Tool |
|----------------------|------|
| `CLAUDECODE=1` | Claude Code |
| `CURSOR_AGENT=1` | Cursor |
| Neither | GitHub Copilot CLI |

> Note: Cursor may not set `CURSOR_AGENT=1` in some versions due to a known bug. In that case, it will fall back to the Copilot icon.

**2. OS detection**

| Condition | Environment |
|-----------|-------------|
| `WSL_DISTRO_NAME` is set, or `/proc/version` contains `microsoft` | WSL |
| `uname -s` = `Darwin` | macOS |
| `uname -s` starts with `MINGW` / `MSYS`, or `OS=Windows_NT` | Windows (Git Bash) |
| Otherwise | Linux |

## License

[MIT](LICENSE) © khayasaka@gmail.com
