#!/bin/bash
# read-config.sh — source this to export Sensei config as env vars.
#
# Usage (from any sub-skill script):
#   source "$(dirname "$0")/../setup/read-config.sh"
#
# Exports:
#   SENSEI_STORAGE_DIR
#   SENSEI_LINK_STYLE
#   SENSEI_RETRIEVAL_DAYS
#   SENSEI_OBSIDIAN_VAULT_NAME (empty if link_style != obsidian)
#
# If the config is missing, prints a message to stderr and exits 1 so the
# caller can bail out with a clear user-facing error.

CONFIG_FILE="$HOME/.claude/sensei/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "⛩️  Sensei config not found at $CONFIG_FILE" >&2
    echo "    Run /sensei setup (or bash ~/.claude/skills/sensei/setup/setup.sh) first." >&2
    exit 1
fi

eval "$(python3 - <<'PY'
import json, os, shlex
with open(os.path.expanduser("~/.claude/sensei/config.json")) as f:
    cfg = json.load(f)
print(f"export SENSEI_STORAGE_DIR={shlex.quote(cfg.get('storage_dir',''))}")
print(f"export SENSEI_LINK_STYLE={shlex.quote(cfg.get('link_style','plain'))}")
print(f"export SENSEI_RETRIEVAL_DAYS={shlex.quote(str(cfg.get('spaced_retrieval_days',7)))}")
print(f"export SENSEI_OBSIDIAN_VAULT_NAME={shlex.quote(cfg.get('obsidian_vault_name',''))}")
PY
)"
