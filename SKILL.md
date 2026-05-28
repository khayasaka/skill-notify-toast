---
name: notify
description: Display a cross-platform toast notification with a tool-specific icon. This skill should be used when the user asks to "notify me", "send a notification", or "alert me when done", when a long-running task completes and the user should be informed of the result, when Claude needs user input or a decision to proceed, or when something requires the user's immediate attention.
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
bash "$HOME/.claude/skills/notify/scripts/run.sh" "$TITLE" "$MESSAGE"
```
