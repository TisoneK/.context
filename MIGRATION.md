# Migrating a Project to the Current Core

Sync is meant to be **one command, then fill the facts**. This page is that
recipe, plus the two special cases (the 0.18 rename, and pre-0.2.0 flat
layouts) that need an extra step.

## Core 0.18 — any 0.2.0–0.17.0 project → Context Ledger (`.context_ledger/`)

Core 0.18 renamed the project directory `.context/` → `.context_ledger/`
and the tools `context-*` → `ledger-*` (see the 0.18.0 CHANGELOG entry).
Memory files, formats, and the two-zone model are unchanged — this is a
rename, not a redesign. The 0.18 tooling detects both layouts, so a
project that updates without renaming keeps working; `rename` is the
explicit finishing step. Three commands, from the project repo root,
with a fresh package checkout reachable (a sibling `../context-ledger`
clone freshened, or `LEDGER_PKG=/path/to/context-ledger`):

```bash
sh .context/core/bin/context-sync update    # old tool swaps in core 0.18; its self-re-exec
                                            # errors — expected, 0.18 is in place
sh .context/core/bin/ledger-sync migrate    # new tool: backfill + relock + verify
sh .context/core/bin/ledger-sync rename     # git mv .context -> .context_ledger + sweep entry points
```

**On Windows:** the same three steps with `.context\core\bin\*.cmd`
(the `.cmd` launchers need no execution-policy change).

`migrate` backfills every zone/file newer releases added, LF-normalizes,
relocks, and verifies; it prints the fill-facts step (kickoff Project
Facts, `AGENTS.md` `<PROJECT_NAME>`, `memory/workflows/active.md`
both-edition paths) when the template changed. `rename` requires a
**clean tree** — commit the migrate first — then `git mv`s the
directory, sweeps the generated entry points (`README.md`, `kickoff.md`,
`.gitattributes`, root `AGENTS.md` + `CLAUDE.md`), relocks, and
verifies. It is safe to run on a project that already reached core 0.18
but skipped the rename (mode detection accepts both directory names).

The **one manual step** `rename` prints: sweep stale `.context/`
*instruction* references in your memory files (historical log entries
stay as written — append-only).

Commit + push: `chore(ledger): rename .context/ to .context_ledger/ (core 0.18)`.

### If `update` errors oddly (project predates 0.16, core < 0.16.0)

The vendored `context-sync` may lack the self-re-exec handoff. Run
`update` (it swaps in a current-enough core regardless), then continue
with `ledger-sync migrate` + `ledger-sync rename` as above.

## The easy path — any 1.0 project → current

From the project repo root, with a fresh package checkout reachable (a
sibling `../context-ledger` clone freshened, or
`LEDGER_PKG=/path/to/context-ledger`):

```bash
sh .context_ledger/core/bin/ledger-sync migrate
```

That single command updates the vendored core to the newest reachable
version, backfills every zone/file newer releases added (`history/`,
`archive/`, `CLAUDE.md`, `.gitattributes`, `roster.md`, `history.conf`,
`GROUP`, …), LF-normalizes the core, relocks, and verifies. It is
idempotent — safe to run again. Then it prints the **one manual step**:

- **`.context_ledger/kickoff.md`** — refill Project Facts (remote URL, default
  branch, project name) if its template changed.
- **`AGENTS.md`** — `<PROJECT_NAME>`.
- **`memory/workflows/active.md`** — protocol *"by agent type"*, both edition
  paths under `.context_ledger/core/rules/`.

Commit + push: `chore(ledger): migrate to core <version>`.

**On Windows:** `.context_ledger/core/bin/ledger-sync.cmd migrate` (the `.cmd`
launcher needs no execution-policy change).

### If `migrate` isn't recognized (project predates it, core < 0.16.0)

The vendored script is too old to have `migrate`. Run `update` once — it
installs a script that has it — then `migrate`:

```bash
sh .context_ledger/core/bin/ledger-sync update    # swaps in a current-enough core
sh .context_ledger/core/bin/ledger-sync migrate   # backfills + verifies + fills-facts prompt
```

From core 0.16.0 onward, a plain `update` already hands off to `migrate`
internally, so one command is enough.

### Windows / CRLF note

The installed `.context_ledger/.gitattributes` forces `eol=lf`, so future checkouts
stay correct. If the project ever committed CRLF blobs, run once after
migrating: `git add --renormalize . && git commit -m "chore(ledger): normalize line endings to LF"`.

---

## Special case: pre-0.2.0 (flat layout) → current

For projects bootstrapped before 0.2.0 — a **flat** `.context/` (memory files
at the top level, `SYNC.md`, no `core/` or `memory/` zones, protocol read
from a sibling clone). These need the two-zone layout created by
hand **first**, then the core-1.0 path at the top of this page.

One session, one commit, **zero data loss**: every memory file moves with
`git mv` (history preserved).

```bash
# 0. Preconditions: clean tree, flat layout confirmed
git status --short                  # must be empty
ls .context/core 2>/dev/null && echo "already migrated — use the paths above"

# 1. Move ALL memory into the memory/ zone (git mv — never cp)
cd .context && mkdir memory
git mv agents inefficiencies plans reviews system tasks user workflows memory/ 2>/dev/null
git mv flaws memory/ 2>/dev/null
git mv secrets memory/ 2>/dev/null || mv secrets memory/   # mostly untracked
cd ..

# 2. Retire the old structural files
git rm .context/SYNC.md 2>/dev/null
git rm .context/README.md
[ -f .context/kickoff.md ] && git rm .context/kickoff.md

# 3. Vendor the core, then run the one-command migrate to finish everything
cp -R ../context-ledger/core .context/core
sh .context/core/bin/ledger-sync migrate
```

Step 3's `migrate` seeds `.context/README.md`, `kickoff.md`, `AGENTS.md`, the
`history/`/`archive/` zones, and every current file, then verifies and prints
the fill-facts step. Finish that step, run **`ledger-sync rename`** (the
core-0.18 rename above), then:

4. **Update `memory/workflows/active.md`** to the current template shape:
   protocol **"by agent type", naming BOTH editions** at their
   `.context_ledger/core/rules/` paths; replace any raw protocol-source URLs with
   "Protocol location: vendored in `.context_ledger/core/`" + a "Package upstream"
   URL.
5. **Path sweep:** update stale `.context/<module>` *instruction* references
   in memory files (not historical log entries — append-only history stays
   as written).
6. **Commit as one commit and push:**
   `chore(ledger): migrate to core 0.18 (two-zone + rename)` — then log
   a session entry noting the migration and the core version.

## What changed across the eras (for the record)

| pre-0.2.0 | 0.2.0–0.17.0 | 0.18 (Context Ledger) |
|---|---|---|
| Flat `.context/`, protocol in a sibling clone | Two-zone `.context/`, vendored core | Same two zones, renamed `.context_ledger/` |
| Memory files flat under `.context/` | Under `.context/memory/` (same modules, same formats) | Under `.context_ledger/memory/` (unchanged formats) |
| `SYNC.md` basename rule | Zone ownership: core replaced whole, memory never touched | Unchanged |
| Package PAT for cloud sessions | Bootstrap-only; sessions need no package access | Package is public — no package PAT at all |
| No integrity/fallback | `ledger-sync verify` / `rollback` + `memory/core.lock` | Unchanged |
| Manual multi-step sync | `ledger-sync migrate` — one command + fill the facts | Unchanged |
