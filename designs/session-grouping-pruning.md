# Design: Session Grouping & Pruning (three-zone lifecycle)

**Status:** implementing
**Proposed:** 2026-09-05 (from the maintainer's spec
`context-session-pruning-spec.md`; the spec fixes WHAT, delegates HOW)
**Target:** core 0.13.0 (MINOR — additive zones + a new `context-history`
helper; the one behavioural change is that `agents/sessions.md` stops being
append-only-forever and becomes the *current group's* registry, which is
backward-compatible: rotation only begins at the first group close.)

---

## What the spec fixes, and the one scoping decision everything hangs on

The spec wants session history collected into **closed groups** that move
`memory/` (live) → `history/` (closed, readable) → `archive/` (cold, zipped)
→ deletion, so nothing grows unbounded and a new group starts clean.

**The load-bearing HOW decision — what a "group" contains.** Read literally,
requirement 2 ("a new group must not inherit terminology, decisions, open
threads") plus requirement 3 ("`memory/` holds only the current group")
would reset *all* of `memory/` each group — including `user/identity.md`,
`system/environments.md`, and `plans/decisions.md`. That breaks the
protocol's spine: durable facts must persist, and ADRs are
"respected, not relitigated." So I scope a **group to the session-history
subtree**, not to all of memory:

- **Grouped (rotates through the zones):** the per-session record —
  `agents/sessions.md` entries, `sessions/SUMMARY.md` lines, and
  `sessions/<date-N>/notes.md`. This is the stream that grows unbounded
  today, and it is exactly what the three zones are for.
- **Durable, cross-group (stays in `memory/`, never rotates):**
  `user/`, `system/`, `plans/decisions.md`, `tasks/backlog.md`,
  `flaws/log.md`, `inefficiencies/log.md`. These have their *own* hygiene
  (update-in-place, and `context-mem prune`/archive from 0.12.0).
- **The spec's "no carryover" intent is enforced at the boundary, not by
  wiping memory:** closing a group runs a **promotion checklist** — every
  open thread in the closing group (unfinished backlog item, in-flight task,
  unresolved flaw, a decision still in force) must already live in its
  durable domain file, or be restated there, *before* the group closes. The
  new group then starts with a clean session stream and no implicit
  carryover — anything that survives did so because it was explicitly
  promoted, precisely as the spec asks. This generalises the existing
  per-session promotion rule to the group boundary.

Collaboration events (`collaboration/events/`, core 0.6.0) are their own
immutable trail and are **out of scope** — grouping does not touch them, per
the spec's non-goal.

## Zone layout

```text
.context/
├── core/                     # vendored protocol (unchanged)
├── memory/                   # LIVE — read at session start
│   ├── agents/sessions.md    # the CURRENT group's session registry
│   ├── sessions/SUMMARY.md   # the current group's summary lines
│   └── ... durable files ...
├── history/                  # CLOSED groups, readable — NOT read at startup
│   ├── README.md
│   └── group-<NNN>.md        # one condensed record per recently-closed group
└── archive/                  # COLD storage — NOT read at startup
    ├── README.md
    └── group-<NNN>.tar.gz    # zipped older groups (auto)
```

`history/` and `archive/` are new top-level zones under `.context/`, added by
bootstrap. Neither is in the session-start reading order — the schema and
both editions state this explicitly, and their READMEs say "audit/lookback
only."

## Resolved Open Decisions

| Decision | Resolution | Why |
|---|---|---|
| **Close trigger** | Hybrid: mechanical default = **session count** (`group_size`, default **20**); manual **milestone close** any time. No time window. | Count is deterministic and weak-agent-safe; sporadic projects make time windows meaningless; milestones need human judgement, so they're the manual override. |
| **Group naming** | Sequential, zero-padded `group-<NNN>` (001, 002, …). Date range + session span recorded *inside* the file. | Sortable, unambiguous; a group spans arbitrary dates, so a calendar name would lie. |
| **History file content** | **Condensed**: the group's `agents/sessions.md` entries + its SUMMARY lines, consolidated into one readable `group-<NNN>.md`. Raw `notes.md` are disposable — deleted at close (already the model) or swept into the group's archive tarball. | Keeps `history/` readable and bounded; the permanent proof-of-session survives as the condensed record. |
| **history → archive trigger** | Keep the last **`history_keep`** (default **3**) closed groups readable in `history/`. When the next group closes, the oldest `history/` group is zipped into `archive/`. | A short readable window covers realistic lookback; older groups go cold automatically. |
| **archive forced-delete** | When `archive/` exceeds **`archive_keep`** (default **12**) tarballs, **oldest-first** deletion down to the cap. Forced, no exemptions. Runs only via the explicit `context-history gc` subcommand. | The spec demands a hard cap and consistency (no ad-hoc exemptions). Isolating deletion in `gc` keeps the one destructive step deliberate. |
| **Deletion safety** | `gc` removes tarballs from the **working tree** and commits — they remain recoverable in **git history**. No history rewriting. | Bounds what agents clone/navigate and read, without an irreversible data-destroying `filter-repo`. Durable knowledge was promoted before archiving, so a deleted cold group holds only raw history. |
| **Promotion mechanism** | A close-time checklist (see above): open threads must be captured in their durable domain before the group closes. Durable files persist across the boundary; the session stream resets. | Reuses the proven per-session promotion rule; satisfies "no implicit carryover" without wiping durable memory. |
| **Config** | `memory/workflows/history.conf` — `group_size`, `history_keep`, `archive_keep`. Absent = the defaults above. | Mirrors the existing `gates.conf` pattern; project-tunable, weak-agent-safe defaults. |

## Implementation

`core/bin/context-history` (POSIX) + `context-history.ps1`:

- **`status`** — current group number, sessions in it (count vs `group_size`),
  `history/` and `archive/` sizes, whether a close is due.
- **`close [--milestone "<label>"]`** — consolidate the live
  `agents/sessions.md` + `SUMMARY.md` into `history/group-<NNN>.md`
  (recording date range, session span, and the milestone label if given);
  reset the live registry/SUMMARY to an empty new group `NNN+1`; if
  `history/` now exceeds `history_keep`, zip the oldest readable group into
  `archive/`. Prints the promotion checklist first and refuses to proceed
  past it silently. Non-destructive (moves + zips only).
- **`gc`** — the only destructive step: delete oldest `archive/` tarballs
  over `archive_keep` (git-recoverable), printing exactly what it removed.

Bootstrap creates `history/` and `archive/` (with READMEs) and seeds the
current group as `group-001`. Both editions gain a short "Session grouping"
subsection (the close step, the promotion checklist, and "never read
`history/`//`archive/` at startup"); the schema documents the zones and the
grouped `agents/sessions.md` mode; `context-sync manifest` is regenerated.

The `.ps1` port mirrors the tested POSIX logic; per the standing note it
cannot run on the maintainer's Mac (no `pwsh`) and owes a Windows pass.

## Non-goals (unchanged from the spec)

- No fixed batch size / window / naming imposed beyond the tunable defaults.
- No change to the collaboration/event layer.
- No git-history rewriting (working-tree bounding only).
