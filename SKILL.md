---
name: notify
description: Display a cross-platform toast notification with a tool-specific icon. This skill should be used only when the user explicitly asks to "notify me", "send a notification", or "alert me when done". Task completion, questions and permission prompts are notified automatically by mods, so do not call this skill on your own for them.
argument-hint: [title] [message]
allowed-tools: [Bash]
license: MIT
---

# notify skill

Displays a toast notification with the given title and message.
Automatically detects the running AI tool and OS environment.

## Usage

```
/notify [title] [message]
```

## Steps

Run the following command with an appropriate title and message:

```bash
NOTIFY=$(echo "$HOME/.claude/skills/notify/scripts/run.sh" | sed 's|^/\([a-zA-Z]\)/|\1:/|')
bash "$NOTIFY" "$TITLE" "$MESSAGE"
```
