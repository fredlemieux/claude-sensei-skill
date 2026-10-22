#!/bin/bash
# sensei-indicator.sh — UserPromptSubmit hook
#
# Injects Sensei Mode state into conversation context on every prompt.
# Works standalone with any Claude Code setup.
#
# Per-session isolation: uses TERM_SESSION_ID (or CLAUDE_SESSION_ID) so each
# terminal has its own Sensei state.
#
# TRIGGER: UserPromptSubmit
# OUTPUT: <sensei-mode> system-reminder tag if active, nothing if inactive
#
# Installation — add to ~/.claude/settings.json under hooks.UserPromptSubmit:
#   { "type": "command", "command": "~/.claude/skills/sensei/hooks/sensei-indicator.sh" }

SESSION_KEY="${TERM_SESSION_ID:-${CLAUDE_SESSION_ID:-global}}"
SENSEI_FILE="$HOME/.claude/session-env/sensei-active-${SESSION_KEY}"

if [ -f "$SENSEI_FILE" ] && [ "$(cat "$SENSEI_FILE" 2>/dev/null)" = "1" ]; then
    echo "<sensei-mode>SENSEI MODE ACTIVE — Guide, don't solve. Question before answering. See ~/.claude/skills/sensei/SKILL.md for full rules.</sensei-mode>"
fi
