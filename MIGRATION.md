# Migrating a Project to the Current Core

Sync is meant to be **one command, then fill the facts**. This page is that
recipe, plus the one special case (pre-0.2.0 flat layouts) that needs a
manual step first.

## The easy path — any 0.2.0+ project → current

From the project repo root, with a fresh package checkout reachable (a
sibling `../context` clone freshened, or `CONTEXT_PKG=/path/to/context`):

```bash
sh .context/core/bin/context-sync migrate
```

That single command updates the vendored core to the newest reachable
version, backfills every zone/file newer releases added (`history/`,
`archive/`, `CLAUDE.md`, `.gitattributes`, `roster.md`, `history.conf`,
`GROUP`, …), LF-normalizes the core, relocks, and verifies. It is
idempotent — safe to run again. Then it prints the **one manual step**:

- **`.context/kickoff.md`** — refill Project Facts (remote URL, default
  branch, project name) if its template changed.
- **`AGENTS.md`** — `<PROJECT_NAME>`.
- **`memory/workflows/active.md`** — protocol *"by agent type"*, both edition
  paths under `.context/core/rules/`.

Commit + push: `chore(context): migrate to core <version>`.

**On Windows:** `.context/core/bin/context-sync.cmd migrate` (the `.cmd`
launcher needs no execution-policy change).

### If `migrate` isn't recognized (project predates it, core < 0.16.0)

The vendored script is too old to have `migrate`. Run `update` once — it
installs a script that has it — then `migrate`:

```bash
sh .context/core/bin/context-sync update    # swaps in a current-enough core
sh .context/core/bin/context-sync migrate   # backfills + verifies + fills-facts prompt
```

From core 0.16.0 onward, a plain `update` already hands off to `migrate`
internally, so one command is enough.

### Windows / CRLF note

The installed `.context/.gitattributes` forces `eol=lf`, so future checkouts
stay correct. If the project ever committed CRLF blobs, run once after
migrating: `git add --renormalize . && git commit -m "chore(context): normalize line endings to LF"`.

---

## Special case: pre-0.2.0 (flat layout) → current

For projects bootstrapped before 0.2.0 — a **flat** `.context/` (memory files
at the top level, `SYNC.md`, no `core/` or `memory/` zones, protocol read
from a sibling `../context` clone). These need the two-zone layout created by
hand **first**, then the easy path above.

One session, one commit, **zero data loss**: every memory file moves with
`git mv` (history preserved).

```bash
# 0. Preconditions: clean tree, flat layout confirmed
git status --short                  # must be empty
ls .context/core 2>/dev/null && echo "already migrated — use the easy path"

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
cp -R ../context/core .context/core
sh .context/core/bin/context-sync migrate
```

Step 3's `migrate` seeds `.context/README.md`, `kickoff.md`, `AGENTS.md`, the
`history/`/`archive/` zones, and every current file, then verifies and prints
the fill-facts step. Finish that step, then:

4. **Update `memory/workflows/active.md`** to the current template shape:
   protocol **"by agent type", naming BOTH editions** at their
   `.context/core/rules/` paths; replace any raw protocol-source URLs with
   "Protocol location: vendored in `.context/core/`" + a "Package upstream"
   URL.
5. **Path sweep:** update stale `.context/<module>` *instruction* references
   in memory files (not historical log entries — append-only history stays
   as written).
6. **Commit as one commit and push:**
   `chore(context): migrate to core <version> (two-zone + current)` — then log
   a session entry noting the migration and the core version.

## What the two-zone model changed (for the record)

| pre-0.2.0 | 0.2.0+ |
|---|---|
| Protocol in a sibling clone, fetched per session | Vendored at `.context/core/`, versioned + checksummed |
| Memory files flat under `.context/` | Under `.context/memory/` (same modules, same formats) |
| `SYNC.md` basename rule | Zone ownership: core replaced whole, memory never touched |
| Package PAT for cloud sessions | Bootstrap-only; sessions need no package access |
| No integrity/fallback | `context-sync verify` / `rollback` + `memory/core.lock` |
| Manual multi-step sync | `context-sync migrate` — one command + fill the facts |
