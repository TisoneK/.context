# Design: Feature-Scoped Memory (`memory/features/`)

**Status:** exploring — design proposal, not yet in core
**Proposed:** 2026-07-18 (maintainer; seeded by gaps surfaced in an
external review conversation)
**Target:** core 0.4.0 (MINOR — additive memory module + one amended
invariant). Was 0.3.0; retargeted 2026-07-21 when the harvest feature
shipped as 0.3.0 while this remained a design.

---

## Problem

Two related gaps in core 0.2.0:

1. **No archival story.** Every log is append-only forever. Per-entry
   statuses (`superseded`, `fixed in package`, checked-off backlog
   items) tell an agent what is still believed, but nothing bounds
   growth: a year into a project, `inefficiencies/log.md` is mostly
   resolved history that every session still reads at startup, because
   it sits in the mandatory reading order.
2. **"What is being worked on" is a single overwrite file.**
   `tasks/current.md` holds one task and doubles as the concurrency
   lock, but there is no first-class record of the *feature* in
   flight — when it started, how it is going, what has been tried —
   that survives across the many sessions a feature spans.

The root cause of (1): memory is partitioned by **record type**
(flaws, plans, tasks), and record types never die — the logs just
grow. Nothing in the layout has a natural end of life, so nothing can
be archived without surgically editing an append-only file.

## Core insight

A **feature** is the unit that actually has a lifecycle: it starts,
it is worked across sessions, it goes functional, it merges to main,
it is done. If feature-lifetime knowledge lives in a partition keyed
by the feature, archival stops being "edit an append-only log" and
becomes "move or delete one directory" — after the feature's summary
has been written to a permanent ledger.

This also drains the growth out of the global logs: feature-grade
detail (attempts, dead ends, per-feature planning) lands in the
feature's own directory instead of the shared files, so the files
every session must read stay small.

---

## Layout

```text
memory/features/
├── ledger.md            # append-only — one line per feature, ever
├── <slug>/              # one directory per feature in flight
│   ├── manifest.md      # update-in-place — status, dates, goal, state
│   └── notes.md         # append-only (while alive) — findings, dead ends
└── archive/<slug>/      # optional cold storage (see Lifecycle §end-of-life)
```

Schema-table rows (extends the Zone 2 inventory):

| Path (under `.context/memory/`) | Mode | Scope | Holds |
|---|---|---|---|
| `features/ledger.md` | append-only | project | One line per feature ever: slug, started, outcome, finished |
| `features/<slug>/manifest.md` | update-in-place | project | Goal, branch, status, started, current state, next steps |
| `features/<slug>/notes.md` | append-only while active; deletable at end-of-life via the ledger rule | project | Feature-scoped findings, attempts, session breadcrumbs |

## The ledger rule (the one amended invariant)

The append-only guarantee is one of the two rules nothing can
override. This design does not override it — it **amends it in core**,
which is why this is a core release, not a project override:

> A feature directory may be moved to `features/archive/` or deleted
> **only after** its ledger line records the outcome (merged `<sha>` /
> abandoned + reason) and the finish date. The ledger line is what the
> append-only guarantee protects; the directory is working state, like
> `tasks/current.md`.

Deletion without a completed ledger line remains a violation. The
ledger is append-only forever and is deliberately one line per
feature — it cannot become the next unbounded log.

## Lifecycle

`planned → in-progress → functional → merged | abandoned → archived`

- **planned** — directory created from templates; goal + slug set.
- **in-progress** — sessions are working it. `tasks/current.md` names
  the slug (see Integration).
- **functional** — works end-to-end; pending review/merge. This is the
  state the maintainer's "if it's functional we merge to main" gate
  reads.
- **merged / abandoned** — terminal outcome. Ledger line completed
  with the merge sha (or the abandonment reason).
- **archived** — end-of-life applied: directory moved to
  `features/archive/<slug>/` (default) or deleted (allowed; the ledger
  line already carries the permanent record). Archiving is a normal
  session step, not a special ritual — any session that notices a
  merged feature's directory still in the hot path may archive it.

## The time-scoping rule

Only facts that **die with the feature** go in its directory. Anything
true beyond the feature's lifetime goes to its existing domain:

- an architectural decision → `plans/decisions.md` (ADR)
- a user preference → `user/preferences.md`
- an environment fact → `system/environments.md`
- protocol friction → `flaws/log.md`

Litmus (mirrors the contamination rules' question): *"would this fact
still matter after the feature merges or is abandoned?"* If yes, it
does not belong in the feature directory. This is the existing
fact-scoping discipline extended to time; without it, archiving a
feature silently deletes durable knowledge.

## Integration points

- **`tasks/current.md`** gains a `Feature: <slug> | none` line. The
  lock file and the feature system connect instead of competing:
  current.md still answers "may I start?", the manifest answers "where
  was this feature left?".
- **Reading order** (session start) gains, after `tasks/current.md`:
  `memory/features/ledger.md` (skim) → the active feature's
  `manifest.md` + `notes.md` (only the feature named in current.md —
  not every directory).
- **Exit checklist** gains: update the active feature's `manifest.md`
  (status, current state, next steps); on merge/abandon, complete the
  ledger line.
- **Reviews** stay global (`reviews/YYYY-MM-DD-*.md`) but name the
  feature slug in the title/header, so a feature's review trail is
  greppable before and after archival.
- **Git:** feature memory is committed like all memory. On a feature
  branch it travels with the code and merges with it — separate
  directories per feature make concurrent branches naturally
  conflict-free in memory, unlike two branches appending to one shared
  log.
- **Concurrency:** unchanged. `tasks/current.md` remains the single
  lock (one agent per repo); multiple feature *directories* coexisting
  is normal and is the point.

## The no-feature path

Hotfix- and chore-sized sessions must not be forced to invent slugs
(weak agents will fabricate ceremony to comply). `Feature: none` in
`tasks/current.md` is fully sanctioned; such sessions touch no feature
directory and write the global logs exactly as in 0.2.0. Rule of
thumb: multi-session work gets a feature; single-session work does not
need one.

## Weak-agent floor

Tier-1 (`AGENTS.md` digest) gains one line: *"multi-session work is
tracked under `.context/memory/features/<slug>/manifest.md` — read the
active one (named in `tasks/current.md`) before starting; update it
before you stop."* Minimal compliance is manifest-only (no notes.md,
no archival) — an agent that does only that does less, but nothing
wrong.

## Templates (to be added under `core/templates/memory/features/`)

`ledger.md`:

```markdown
# Feature Ledger (append-only — permanent, one line per feature)

<!-- TEMPLATE — copy below the last entry:
- **<slug>** — started YYYY-MM-DD · <merged <sha> | abandoned: <reason> | active> · finished YYYY-MM-DD | —
-->
```

`manifest.md` (per-feature, update-in-place):

```markdown
# Feature: <slug>

- **Goal:** <one paragraph — what done looks like>
- **Started:** YYYY-MM-DD
- **Branch:** <branch or "main">
- **Status:** planned | in-progress | functional | merged | abandoned
- **Current state:** <where work stands — updated every session>
- **Next steps:** <what the next session should do first>
```

`notes.md` (per-feature, append-only while active):

```markdown
# Notes: <slug> (append-only while the feature is alive)

<!-- TEMPLATE — copy below the last entry:
---
## YYYY-MM-DD — <agent> / <model> (Session N)
<findings, attempts, dead ends — detail that would otherwise bloat the
global logs. Facts that outlive the feature go to their real domain.>
-->
```

## Folded-in small fix

The ADR template (`plans/decisions.md`) is the one record type without
an author line; every other template carries `<agent> / <model>`. The
same release adds:

```markdown
- **Author:** <agent> / <model> (Session N)
```

## Rollout

Additive MINOR (0.2.x → 0.3.0): new `features/` template tree, the
amended append-only wording in both editions + schema (md and json),
the `Feature:` line in the `tasks/current.md` template, reading-order
and exit-checklist edits, AGENTS.md digest line, ADR author line,
manifest regen. Existing projects need no memory migration — the
directory appears on first use; old `tasks/current.md` files without a
`Feature:` line read as `Feature: none`.

## Open questions

1. **Archive vs delete default** — proposal says archive is default,
   delete is allowed. Is delete too sharp for the first release, given
   how hard "never delete" has been drilled? Alternative: 0.3.0 ships
   archive-only; delete becomes legal in a later release once the
   ledger habit is established.
2. **Slug discipline** — kebab-case, assigned once, never renamed
   (renames orphan the ledger). Enforced by prose or by `check` (MVP
   feature 2)?
3. **Does `plans/` fold in later?** Feature-scoped *plans* naturally
   live in the manifest; `plans/decisions.md` (ADRs) stays global.
   Watch whether anything else in `plans/` still earns its place.
4. **`check` integration** — exit-readiness (`check --exit`) should
   eventually verify: active feature's manifest touched this session;
   no feature directory deleted without a completed ledger line.
