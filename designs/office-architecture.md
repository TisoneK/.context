# Design: Office Architecture (directory-per-office memory layout)

**Status:** shipped
**Proposed:** 2026-09-11 (from the maintainer's vision, refined across the
design session: one live office, numbered only when archived, frozen
verbatim, permanent accomplishments record)
**Target:** core 1.0.0 (MAJOR — the memory layout changes: the live group
moves from flat paths into `memory/office/`; installs migrate during
`ledger-sync update`)

Supersedes the memory-layout parts of `session-grouping-pruning.md`
(0.13.0): groups become offices, the live group becomes a directory, the
condensed `group-<NNN>.md` history file is replaced by the frozen office
directory plus a permanent record. Collaboration events (0.22.0) are
unaffected.

---

## The vision (the maintainer's words, operationalized)

One **office** is live at a time — the people (agents) work in it, the
roster is the board by the door, and when the office fills up it is
archived **whole**: every shift it recorded stays intact ("even the
rosters will stay intact, no trimming"). The next office begins from
ground zero — nothing left behind to distract or misdirect the agents who
walk in. Only **history** is referred to deliberately: each archived
office gets a permanent record in `history/` "so that it never gets
forgotten about the things it accomplished." The live office is never
numbered; the number is stamped once, at archive time ("the number comes
during archiving, not in office").

## The model

- **Live office:** `.context_ledger/memory/office/` — unnumbered, stable
  paths (only one office is ever live, so no dynamic path discovery
  anywhere in the protocol). Holds everything **session-produced**:
  `agents/` (sessions.md registry + roster.md), `sessions/` (SUMMARY +
  dated notes), `tasks/` (current.md, backlog.md), `plans/decisions.md`,
  `flaws/`, `inefficiencies/`, `reviews/`.
- **Durable files** stay at the `memory/` root and never rotate:
  `workflows/`, `collaboration/` (events trail), `system/`, `user/`,
  `overrides/`, `core.lock`, `secrets/`. The boundary: durable files
  *orient* a session (standing rules, config, registries, the human's
  facts); office files are the session *narrative* that could go stale.
- **Close** (`ledger-history close --confirm`): the directory is moved
  **verbatim** — no condensing, no resetting; the roster keeps every
  check-in/clock-out shift — into `history/office-<NNN>/`. The number is
  derived at that moment from the records (no state file; the permanent
  records never leave, so the sequence is always derivable). A fresh
  office is seeded from `core/templates/memory/office/`.
- **Permanent accomplishments record:** `history/office-<NNN>.md`, written
  by close with auto-facts (number, opened/closed dates, session count,
  milestone) and filled in by the closing session: **Accomplished /
  Decisions still in force / Open threads**. It stays in `history/`
  forever — even after the frozen office is zipped and eventually gc'd,
  the office is never forgotten.
- **Archive:** when `history/` holds more than `history_keep` (3) frozen
  directories, the oldest is zipped to `archive/office-<NNN>.tar.gz` and
  removed; its record stays. `gc` caps tarballs at `archive_keep` (12),
  oldest-first, git-recoverable.
- **No implicit carryover:** the new office starts from empty skeletons.
  Open threads that still matter are **re-seeded** into the new office's
  files by the closing session, after the freeze, and listed in the
  permanent record's "Open threads". Dropped items survive only in the
  frozen office, the record's history, and git — never in a startup read.
  This is the point: stale claims, resolved-but-unpruned log entries, and
  superseded decisions cannot misdirect the next office.
- **Lifecycle knobs:** `office_size` (20, legacy key `group_size` still
  read), `history_keep` (3, counts frozen directories), `archive_keep`
  (12, tarballs). `ledger-gates checkpoint` prints a warn-only notice
  when the office is full — advisory, never blocking (the original
  observation that grouping was unenforced, made into a nudge).

## Why the live office is a directory named `office` (not `group-<NNN>/`)

The session-start reading order, every tool, and every template reference
fixed canonical paths. Numbering the live directory would make every one
of those references dynamic (discover the current group before reading
anything). Naming the live directory `office/` keeps every reference
static; the number exists exactly once in the lifecycle — stamped on the
frozen directory and its permanent record at close.

## What changed in the package

- `ledger-history` (sh + ps1): full rewrite — freeze-at-close, stateless
  numbering, permanent-record stub, fresh-office seeding, directory
  roll-to-archive; Reset-Registry/Reset-Summary/Reset-Roster and the
  `agents/GROUP` state file are gone.
- `ledger-mem` (sh + ps1): office-scoped checks repointed under
  `memory/office/…`; durable system registries unchanged.
- `ledger-sync` (sh + ps1): `migrate_office_layout` runs at the top of
  backfill — a legacy flat layout (agents/, sessions/, tasks/, plans/,
  flaws/, inefficiencies/, reviews/ at the memory root, no office/) is
  grouped into `memory/office/` during any `update` or `migrate`; the
  GROUP counter is removed; `history.conf`'s `group_size` key is renamed
  `office_size`. `bootstrap` seeds the office skeleton via
  `templates/memory/`.
- `ledger-gates` (sh + ps1): checkpoint office-full notice.
- Templates: the office-scoped skeletons moved under
  `core/templates/memory/office/`; zone READMEs and the ledger-README
  tree rewritten; kickoff/AGENTS/CLAUDE reading orders split office vs
  durable paths.
- Schema (`ledger-schema.md` + `ledger.schema.json`): registry split into
  officeFiles and memoryFiles; new historyFiles/archiveFiles sections;
  "Session grouping" section rewritten as "Office lifecycle".

## Migration (old architecture → an office, during sync)

`ledger-sync update` has always handed off to `migrate --backfill-only`
on the just-installed core; the office grouping lives in that path, so
the maintainer's requirement — "old architecture to be grouped as an
office during sync" — needs no new command. Detection is layout-shaped:
no `memory/office/` + flat `memory/agents/` present ⇒ move the seven
group-scoped directories into `office/`, drop `agents/GROUP`, rename the
config key, print the commit instruction. Idempotent; durable files never
move; legacy `history/group-<NNN>.md` files from pre-1.0.0 closes are
left in place as read-only history.

## Trade-offs accepted

- **ADRs and open flaws leave the startup read at office close.** They are
  re-seeded only if the closing session judges them still relevant. The
  permanent record's "Decisions still in force" section is the bridge.
  Accepted deliberately: the maintainer weighed clean starts against
  accumulated context and chose clean starts — history is one deliberate
  lookup away.
- **Close requires a deliberate session.** The freeze, record fill-in,
  and re-seeding are a session's work (one commit), not a cron job —
  matching the protocol's philosophy that memory work is session work.
- **One more directory hop** in every office-scoped path. Cheap; bought
  the stable-names property above.
