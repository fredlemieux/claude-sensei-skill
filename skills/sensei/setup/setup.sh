#!/bin/bash
# setup.sh — First-run config flow for the Sensei skill.
#
# Writes ~/.claude/sensei/config.json with:
#   - storage_dir           (where reports + gaps.md live)
#   - link_style            (plain | obsidian | logseq)
#   - spaced_retrieval_days (int, 0 to disable)
#   - obsidian_vault_name   (only when link_style == obsidian)
#
# Safe to re-run — existing values are offered as defaults.

set -e

CONFIG_DIR="$HOME/.claude/sensei"
CONFIG_FILE="$CONFIG_DIR/config.json"
mkdir -p "$CONFIG_DIR"

# -------- helpers --------
read_existing() {
    local key="$1" default="$2"
    if [ -f "$CONFIG_FILE" ]; then
        local val
        val=$(python3 -c "import json,sys;print(json.load(open('$CONFIG_FILE')).get('$key',''))" 2>/dev/null || echo "")
        [ -n "$val" ] && echo "$val" || echo "$default"
    else
        echo "$default"
    fi
}

prompt() {
    local label="$1" default="$2" varname="$3"
    local reply
    read -r -p "$label [$default]: " reply
    reply="${reply:-$default}"
    eval "$varname=\"\$reply\""
}

# -------- storage dir --------
DEFAULT_STORAGE=$(read_existing storage_dir "$HOME/sensei")
prompt "Where should Sensei store reports and gaps?" "$DEFAULT_STORAGE" STORAGE
STORAGE="${STORAGE/#\~/$HOME}"

# -------- link style --------
DEFAULT_LINK=$(read_existing link_style "plain")
echo
echo "Link style for cross-references in reports:"
echo "  1) plain     — standard Markdown links"
echo "  2) obsidian  — obsidian:// URI links (if your storage is an Obsidian vault)"
echo "  3) logseq    — [[page]] wiki refs"
prompt "Choose [plain/obsidian/logseq]" "$DEFAULT_LINK" LINK
case "$LINK" in
    plain|obsidian|logseq) ;;
    *) echo "Invalid choice, defaulting to plain."; LINK=plain ;;
esac

VAULT_NAME=""
if [ "$LINK" = "obsidian" ]; then
    DEFAULT_VAULT=$(read_existing obsidian_vault_name "$(basename "$STORAGE")")
    prompt "Obsidian vault name" "$DEFAULT_VAULT" VAULT_NAME
fi

# -------- spaced retrieval --------
DEFAULT_DAYS=$(read_existing spaced_retrieval_days 7)
prompt "Spaced-retrieval window in days (0 to disable)" "$DEFAULT_DAYS" DAYS
if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
    echo "Invalid number, defaulting to 7."; DAYS=7
fi

# -------- create storage --------
mkdir -p "$STORAGE/reports"
if [ ! -f "$STORAGE/gaps.md" ]; then
    cat > "$STORAGE/gaps.md" <<'EOF'
---
name: sensei_knowledge_gaps
description: Tracked knowledge gaps from Sensei Mode sessions for spaced retrieval and practice
---

## Active Gaps (will be revisited)

_No gaps tracked yet — they'll appear here after your first Sensei session._

## Closed Gaps (demonstrated competence)

_Nothing closed yet._
EOF
fi

# -------- write config --------
python3 - <<PY
import json, os
cfg = {
    "storage_dir": os.path.expanduser("$STORAGE"),
    "link_style": "$LINK",
    "spaced_retrieval_days": int("$DAYS"),
}
if "$VAULT_NAME":
    cfg["obsidian_vault_name"] = "$VAULT_NAME"
with open(os.path.expanduser("$CONFIG_FILE"), "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
PY

echo
echo "⛩️  Sensei configured:"
echo "    storage        : $STORAGE"
echo "    link style     : $LINK"
[ -n "$VAULT_NAME" ] && echo "    obsidian vault : $VAULT_NAME"
echo "    retrieval days : $DAYS"
echo
echo "Config written to $CONFIG_FILE"
echo "You can now use /sensei on to start a guided session."
