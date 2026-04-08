#!/bin/bash
# MemPalace mine-only SessionEnd hook (generic, dotfile-able version).
#
# On Claude Code SessionEnd, extracts the current session's transcript path
# from stdin JSON, looks up the Claude project basename in ~/.mempalace/wing_map,
# and if it matches launches `mempalace mine` detached in the background.
#
# Never blocks Claude: always emits {} and exits 0 immediately. The actual
# mine runs decoupled via nohup + disown so the hook returns in <100ms while
# the mine continues after the session ends.
#
# Configuration:
#   ~/.mempalace/wing_map          Colon-separated "basename:wing" lines.
#                                  Blank lines and # comments ignored.
#                                  Non-listed projects are skipped silently.
#   ~/.mempalace/hooks/mine.log    Append-only log of triggers + mine output.
#
# See ~/dotfiles/cc/mempalace/README.md for setup instructions.

LOG="$HOME/.mempalace/hooks/mine.log"
WING_MAP="$HOME/.mempalace/wing_map"
MEMPALACE_BIN="$HOME/.local/bin/mempalace"
mkdir -p "$(dirname "$LOG")"

# Always emit empty decision on exit so Claude never blocks, even on errors.
trap 'printf "{}\n"' EXIT

INPUT=$(cat)

# Robust JSON parse via python — no bash string munging on untrusted input.
TRANSCRIPT_PATH=$(printf '%s' "$INPUT" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("transcript_path",""))' 2>/dev/null)
[ -z "$TRANSCRIPT_PATH" ] && exit 0

# Expand ~ if present.
TRANSCRIPT_PATH="${TRANSCRIPT_PATH/#\~/$HOME}"
PROJECT_DIR=$(dirname "$TRANSCRIPT_PATH")
PROJECT_BASENAME=$(basename "$PROJECT_DIR")

# Bail silently if no wing map is configured yet.
[ -f "$WING_MAP" ] || exit 0

# Look up wing for this project basename. Ignores comments and blank lines.
WING=$(awk -F: -v key="$PROJECT_BASENAME" '
  /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
  $1 == key { print $2; exit }
' "$WING_MAP")
[ -z "$WING" ] && exit 0

# Belt-and-suspenders: bail if the mempalace CLI isn't where we expect.
[ -x "$MEMPALACE_BIN" ] || { echo "[$(date '+%Y-%m-%d %H:%M:%S')] mempalace not found at $MEMPALACE_BIN" >> "$LOG"; exit 0; }

TS=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TS] SessionEnd: mining $PROJECT_BASENAME as wing=$WING" >> "$LOG"

# Detach the mine: closed stdin, background, nohup, disowned.
# Hook returns immediately; the mine keeps running after Claude exits.
nohup "$MEMPALACE_BIN" mine "$PROJECT_DIR" --mode convos --wing "$WING" --agent "$(whoami)" --extract general >> "$LOG" 2>&1 < /dev/null &
disown 2>/dev/null || true

exit 0
