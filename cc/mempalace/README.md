# MemPalace setup

[MemPalace](https://github.com/milla-jovovich/mempalace) is a local-only
verbatim conversation memory layer: store every Claude Code session in
ChromaDB, search it semantically, layer it alongside the curated memory
system without conflict.

This directory holds the reusable artifacts. The palace data and
machine-specific config live outside dotfiles in `~/.mempalace/`.

## Architecture

Two memory layers, separated on purpose:

- **Distilled memory** (curated, hand-written): project-scoped files under
  `~/.claude/projects/<project>/memory/*.md`, eager-loaded via `MEMORY.md`.
  This is rules, preferences, project facts, feedback — the opinion layer
  that the auto-memory system describes.
- **Verbatim memory** (firehose, auto-mined): `~/.mempalace/palace/` —
  ChromaDB drawers mined from Claude session transcripts, queried on demand
  via MCP.

Query order for the AI: distilled first (already in context), mempalace
second (on-demand via `mempalace_search`), promote durable rules out of
mempalace hits into distilled memory. The firehose fills, the stock is
decanted.

The refresh mechanism is a SessionEnd hook (`mine_on_session_end.sh`) that
backgrounds a `mempalace mine` on session exit and returns to Claude Code
within ~100ms. No mid-session interruption, no cross-layer write contention.

## Bootstrap on a new machine

### 1. Install the CLI

```bash
uv tool install mempalace
```

Upgrade path: `uv tool upgrade mempalace`. Do this deliberately — the
project iterates fast and has historically had schema-affecting changes
between minor versions.

### 2. Register the MCP server (user scope)

```bash
claude mcp add mempalace --scope user -- \
  "$HOME/.local/share/uv/tools/mempalace/bin/python" -m mempalace.mcp_server
```

Verify with `claude mcp list`.

### 3. Install the hook and per-machine config

```bash
mkdir -p ~/.mempalace/hooks
cp ~/dotfiles/cc/mempalace/mine_on_session_end.sh ~/.mempalace/hooks/
chmod +x ~/.mempalace/hooks/mine_on_session_end.sh

cp ~/dotfiles/cc/mempalace/wing_map.example ~/.mempalace/wing_map
cp ~/dotfiles/cc/mempalace/identity.example.txt ~/.mempalace/identity.txt
```

Edit `~/.mempalace/wing_map` so each line maps a Claude project dir
basename (as it appears under `~/.claude/projects/`) to a wing name.
Only listed projects get mined — everything else is skipped silently.

Edit `~/.mempalace/identity.txt` to describe your role and preferences.
This is the L0 wake-up layer loaded on every `mempalace_status` call.

### 4. Wire the SessionEnd hook into Claude Code

Merge this into the `hooks` object of `~/.claude/settings.json` (do not
replace existing entries):

```json
"SessionEnd": [
  {
    "matcher": "",
    "hooks": [
      {
        "type": "command",
        "command": "/Users/<you>/.mempalace/hooks/mine_on_session_end.sh",
        "timeout": 10
      }
    ]
  }
]
```

Replace `/Users/<you>/` with your actual home directory — Claude Code
does not expand `$HOME` or `~` in settings values.

Validate:
```bash
jq -e '.hooks.SessionEnd[] | .hooks[] | .command' ~/.claude/settings.json
```

### 5. Seed the palace with existing transcripts

For each project you listed in `wing_map`:

```bash
mempalace mine ~/.claude/projects/<basename> --mode convos --wing <wing> --extract general
```

The miner tracks already-filed files and skips them, so re-runs are
cheap. Future refreshes happen automatically via the SessionEnd hook.

## How the hook decides to mine

1. `SessionEnd` fires. Claude Code pipes session JSON on stdin.
2. Hook extracts `transcript_path`, derives the Claude project dir.
3. Looks up `basename($PROJECT_DIR)` in `~/.mempalace/wing_map`.
4. If matched: logs to `~/.mempalace/hooks/mine.log`, launches
   `mempalace mine ... --extract general` via `nohup ... & disown`,
   returns `{}`.
5. If not matched: silently exits with `{}`. No side effects.

The mine keeps running after Claude Code exits. Output appended to
`~/.mempalace/hooks/mine.log`.

## Gotchas

- **`--extract general` over-classifies into `emotional`.** The regex
  classifier picks up debugging-frustration tokens (fail, broken, issue,
  wrong) as emotional content. On a coding project the `emotional` room
  is the noise bucket — filter searches by `room=decision|problem|
  milestone` for high-signal cuts, or omit `--room` entirely and let
  semantic search do the work.
- **`mempalace status` display caps at 10000 drawers.** The real count
  is larger; search works on the full set regardless.
- **Do NOT install the shipped `mempal_save_hook.sh` or
  `mempal_precompact_hook.sh`.** They block Claude mid-session and
  instruct it to write to memory, which conflates the distilled and
  verbatim layers. The SessionEnd hook in this dir is the cleaner path:
  refresh only on clean session exit, no mid-session interruption, no
  risk of the AI writing to curated memory without discipline.
- **Palace schema risk on upgrade.** CLI code upgrades via
  `uv tool upgrade` are safe, but if a future mempalace version bumps
  its chromadb range the palace may need rebuilding. Review release
  notes before upgrading.
- **Unclean session exits skip the hook.** If Claude Code is killed or
  crashes, SessionEnd may not fire and the palace stays stale until the
  next clean exit or a manual re-mine. Re-mines are idempotent.
- **Cross-contamination with curated memory.** If your curated memory
  dir lives inside a mined Claude project dir (default layout does
  this), `mempalace mine` will pick up and index those files. Harmless
  but mildly self-referential — your reference memory entries may
  surface in semantic searches of the palace.
