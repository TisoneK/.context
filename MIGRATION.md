# Migrating a Project to Core 0.2.0 (the two-zone layout)

For projects bootstrapped before 0.2.0 — the ones with a **flat**
`.context/` (memory files at the top level, `SYNC.md`, no `core/` or
`memory/` zones, protocol read from a sibling `../context` clone).

The migration is one session, one commit, **zero data loss**: every
memory file moves with `git mv` (history preserved); nothing is
regenerated except the files whose templates changed (`kickoff.md`,
`.context/README.md`).

An agent can run this. Treat it as a `.context/`-surface session:
`chore(context):` prefix, memory rules apply throughout.

## Steps

From the project repo root, with the package clone as a sibling
(`../context`, freshened — find it by remote URL, never by name):

```bash
# 0. Preconditions: clean tree, flat layout confirmed
git status --short                  # must be empty
ls .context/core 2>/dev/null && echo "already migrated — stop"

# 1. Move ALL memory into the memory/ zone (git mv — never cp)
cd .context && mkdir memory
git mv agents inefficiencies plans reviews system tasks user workflows memory/ 2>/dev/null
git mv flaws memory/ 2>/dev/null
git mv secrets memory/ 2>/dev/null || mv secrets memory/   # mostly untracked — mv is fine
cd ..

# 2. Retire the old structural files (their jobs moved to core/)
git rm .context/SYNC.md 2>/dev/null
git rm .context/README.md          # replaced from core/templates below
OLD_KICKOFF=.context/kickoff.md; [ -f "$OLD_KICKOFF" ] && git rm "$OLD_KICKOFF"

# 3. Vendor the core + seed the new zone files
cp -R ../context/core .context/core
cp .context/core/templates/context-README.md .context/README.md
cp .context/core/templates/kickoff.md .context/kickoff.md
cp -R .context/core/templates/memory/overrides .context/memory/overrides
[ -f AGENTS.md ] || cp .context/core/templates/AGENTS.md AGENTS.md
sh .context/core/bin/context-sync verify   # writes memory/core.lock too
```

Then, by hand (an agent does this from the project's own memory —
formats in each file's HTML comment and in
`.context/core/schemas/context-schema.md`):

4. **Refill `.context/kickoff.md`** Project Facts from memory
   (`memory/user/identity.md`, `memory/workflows/active.md`,
   `git remote get-url origin`). Fill `AGENTS.md`'s `<PROJECT_NAME>`.
5. **Update `memory/workflows/active.md`** to the 0.2.0 template shape:
   protocol **"by agent type", naming BOTH editions** at their new
   `.context/core/rules/` paths; replace the raw/blob "Protocol source"
   URLs with "Protocol location: vendored in `.context/core/`" plus a
   "Package upstream" URL.
6. **Path sweep:** update stale `.context/<module>` self-references in
   memory files where they're *instructions* (e.g. a report pointer
   template) — do NOT rewrite historical log entries; append-only
   history stays as written.
7. **Commit everything as one commit and push:**
   `chore(context): migrate to core 0.2.0 two-zone layout`
   — then log a session entry noting the migration and the core version.

## What changed, for the record

| 0.1.x | 0.2.0 |
|---|---|
| Protocol in a sibling clone, fetched per session | Vendored at `.context/core/`, versioned + checksummed |
| Memory files flat under `.context/` | Under `.context/memory/` (same modules, same formats) |
| `SYNC.md` basename rule (README/.gitignore = structural) | Zone ownership: core replaced whole, memory never touched |
| Package PAT for cloud sessions | Bootstrap-only; sessions need no package access |
| No overrides mechanism | `memory/overrides/rules.md` (beats the edition) |
| No integrity/fallback | `context-sync verify` / `rollback` + `memory/core.lock` |
| No root discovery file | `AGENTS.md` generated at bootstrap |

Old GitHub URLs to `ai-engineering-protocol*.md` at the package root
404 after 0.2.0 (the editions moved to `core/rules/`). Migrated
projects don't fetch by URL anymore, so the only fix needed is the
`workflows/active.md` update in step 5.
