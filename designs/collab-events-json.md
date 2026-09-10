# Design: JSON Collaboration Events (`collab-event.schema.json` v1)

**Status:** accepted — design approved in maintainer session, 2026-09-10
**Proposed:** 2026-09-10 (maintainer, after a design conversation covering
worktree mandates, the chat wall, and event visibility)
**Target:** core 0.22.0 (MINOR — new event representation with
backward-compatible readers; memory zone is never touched by `ledger-sync`,
so old trails keep parsing and no project migration is forced)

---

## Problem

Collaboration events are stored as markdown files with a `---` frontmatter
block and a free-text body. The format works, but it has four structural
weaknesses that surfaced while designing against the real tooling
(`core/bin/ledger-collab`, `core/bin/ledger-collab-check`):

1. **The `none` sentinel.** Absent values are the literal string `none`,
   so every consumer (`paths_overlap`, `distinct_count`, `released`,
   `check`) special-cases it. A missing owner and an owner literally named
   "none" are indistinguishable.
2. **CSV-in-a-string fields.** `paths`, `refs`, and `participants` are
   comma-joined strings split by hand in awk. There is no escaping story,
   and the format cannot express a path that contains a comma.
3. **No version marker on a durable artifact.** Event trails are the one
   memory surface designed to be fetched by *later* agents — possibly
   running a newer core — yet the files carry no schema version. Any
   future format change is blind to old trails.
4. **No machine validation.** Document-level rules (required fields per
   type) are enforced only by `check`'s inline awk; nothing can validate a
   single event file in isolation with standard tooling.

A fifth, protocol-level gap motivates the rollout section: **events exist
only in declared collaboration sessions.** A solo session — the default
mode — leaves no structured trace of what it claimed and released, so an
agent arriving mid-session sees a roster row but no live scope. This
design makes the event light path universal, solo included.

## Core insight

The tools are already mode-agnostic: `emit`/`status`/`check` operate on a
directory. The mode only decides **where that directory lives and who
reads it**. So the JSON representation does not need mode-specific
variants — and once writing an event costs one tool call, the solo light
path (`claim` → work → `release`) becomes the same shape in both modes:
collaboration just adds peers reading the same trail.

## The v1 event document

One file per event at
`.context_ledger/memory/collaboration/events/<id>.json` (legacy events
keep their `<id>.md` names; readers accept both). All 14 keys are always
present — absent optional values are `null` / `[]`, never omitted, so
documents are diff-stable and greppable.

| Field | JSON type | Maps to today | Notes |
|---|---|---|---|
| `schema` | `const: 1` | *(new)* | Version of the event representation; future formats bump it and readers branch on it. |
| `id` | string | `id` | `YYYYMMDDTHHMMSSZ-<agent>-<hex>`; also the filename stem. |
| `type` | enum | `type` | `note · claim · proposal · assessment · agreement · correction · handoff · release`. |
| `session` | string | `session` | Charset `[A-Za-z0-9._:-]+` (what `validate_id` enforces). |
| `agent` | string | `agent` | Same charset. |
| `created` | string | `created` | ISO-8601 UTC, e.g. `2026-09-10T12:51:25Z`. |
| `issue` | string | `issue` | Same charset as session. |
| `body` | string | free-text body | Named after the CLI's `--body`. Multi-line allowed (from `--body-file`); escaped per the strict profile. |
| `paths` | string[] | CSV string | Repo-relative paths or logical scopes. `[]` replaces the `none` sentinel. |
| `refs` | string[] | CSV string | Event IDs and/or commit SHAs (7–40 hex). `[]` replaces `none`. |
| `option` | string \| null | `none` sentinel | Proposal-only. |
| `selected` | string \| null | `none` sentinel | Agreement-only. |
| `owner` | string \| null | `none` sentinel | Agreement (implementer) / handoff (recipient). |
| `participants` | string[] | CSV string | Agreement: agents who accepted. Note: carries `--to` addressees (today `--to` overloads this field; kept faithful). |

The full JSON Schema lives at
`core/schemas/collab-event.schema.json` (draft 2020-12). It validates
**document shape** — per-type required fields. The **relational** rules
(refs resolve to same-session events or SHAs, owner ∈ participants,
selected ∈ referenced proposals, claim closure, path overlap) are
trail-level and remain the authority of `ledger-collab check`; no JSON
Schema can express "this ref resolves to a proposal".

### Per-type requirements (the real state machine, from `ledger-collab-check`)

| Type | Document-level (schema checks) | Trail-level (`check` keeps) |
|---|---|---|
| note | body non-empty | exempt from ref resolution entirely |
| claim | `paths` ≥ 1 | closed by a release/handoff before integration |
| proposal | `option` non-null | resolved by an agreement |
| assessment | `refs` ≥ 1 | ≥ 1 ref is a proposal; resolved by an agreement |
| agreement | `refs`/`selected`/`owner`/`participants` non-empty | refs ≥ 1 proposal + ≥ 1 assessment; owner ∈ participants; ≥ 2 distinct participants; `selected` matches an option in a referenced proposal |
| correction | `refs` ≥ 1 | referenced by an agreement |
| handoff | `owner` non-null | refs a claim/handoff/agreement, or shares session+issue+path with a claim; itself released |
| release | `refs` ≥ 1 | corresponds to a claim/handoff (by ref **or** session+issue+path overlap — the weak-agent fallback) and includes a commit SHA |

## Strict profile (why no new dependency)

The sh port must stay dependency-free (the 0.13.x–0.18.x line of releases
exists because of portability). The writer therefore emits a **strict
profile** that keeps readers as simple as today's `field()`:

- UTF-8, no BOM, LF endings, 2-space indent.
- Key order fixed: `schema, id, type, session, agent, created, issue,
  body, paths, refs, option, selected, owner, participants`.
- **One key per line.** `body` is escaped (`\` → `\\`, `"` → `\"`,
  newline → `\n`, CR → `\r`), and arrays are single-line
  (`["a", "b"]`), so every `"key": value` pair is exactly one line — the
  reader is still `sed`/`awk` line extraction, now with unescaping.
- Only flat types: string, array-of-strings, null, and the `schema`
  integer. No nested objects.

`emit` remains the only writer (agents never hand-write events), so
escaping is centralized. The PowerShell port uses native
`ConvertFrom-Json` and accepts any valid JSON, strict profile or not.

## Solo universality (the protocol change that ships with this)

Solo sessions adopt the light path — **`claim` at start, `release` at
close** — writing to the same `memory/collaboration/events/` directory on
the main branch, committed with the session's normal `chore(ledger):`
memory commits:

- `session`: the session's roster codename (`S<NNN>`); `issue`: a short
  task slug. `emit` already requires both IDs; solo fills them with these
  conventions.
- The claim carries `--paths` for the task scope — this is the piece
  `tasks/current.md` never had. `current.md` stays (the solo lock and
  idle marker); events complement it, they do not replace it.
- The release cites the product commit SHA, which makes the trail a
  per-session work record `check` can validate.

Why this is more than bookkeeping: an agent arriving mid-session sees a
live claim **with paths** the moment it reads the board, in any mode.
Today the arriving peer must wait for the incumbent to notice and
retrofit a claim (the incumbent-side gap in the solo→collab transition);
with universal events the incumbent's scope is public from session start,
and the "claim first, then branch" rule for incumbents shrinks to
"branch" — the claim already exists. A collaboration session that starts
later fetches the coordination branch on top of this trail unchanged.

## Migration

- Readers accept both `.json` (new) and `.md` (legacy) in the same
  events directory; the writer emits only `.json`. Old trails parse
  forever — no conversion required, no forced `ledger-sync update`
  behavior beyond the normal MINOR flow.
- Event files live in `memory/`, which `ledger-sync` never touches, so
  the format change cannot corrupt a vendored project's core update path.
- Semver: MINOR. The readers are backward-compatible and the memory zone
  is project-owned.

## Example documents

A claim (solo or collab — identical shape):

```json
{
  "schema": 1,
  "id": "20260910T125125Z-mei-a1b2c3d4",
  "type": "claim",
  "session": "S427",
  "agent": "mei",
  "created": "2026-09-10T12:51:25Z",
  "issue": "session-validation-refactor",
  "body": "Splitting token refresh out of login. No callers outside src/auth.",
  "paths": ["src/auth/login.ts", "src/auth/session.ts"],
  "refs": [], "option": null, "selected": null, "owner": null, "participants": []
}
```

A note (the chat wall — `--to` lands in `participants`, `--re` in `refs`):

```json
{
  "schema": 1,
  "id": "20260910T130210Z-john-9f3e11ab",
  "type": "note",
  "session": "auth-refactor",
  "agent": "john",
  "created": "2026-09-10T13:02:10Z",
  "issue": "ISS-42",
  "body": "Watch the retry loop in session.ts — I changed its signature on my branch.",
  "paths": [],
  "refs": ["20260910T125125Z-mei-a1b2c3d4"],
  "option": null, "selected": null, "owner": null,
  "participants": ["mei"]
}
```

A release (closes the claim; the SHA ref keeps the weak-agent fallback):

```json
{
  "schema": 1,
  "id": "20260910T144400Z-mei-51c0e9d2",
  "type": "release",
  "session": "auth-refactor",
  "agent": "mei",
  "created": "2026-09-10T14:44:00Z",
  "issue": "ISS-42",
  "body": "Merged collab/auth-refactor/mei at e462943; session validation split complete.",
  "paths": [],
  "refs": ["20260910T125125Z-mei-a1b2c3d4", "e462943"],
  "option": null, "selected": null, "owner": null, "participants": []
}
```

## Rollout checklist

- [x] Schema file: `core/schemas/collab-event.schema.json`
- [x] `ledger-collab` (sh): JSON emit (strict profile) + dual-read status
- [x] `ledger-collab-check` (sh): dual-read parser, state machine unchanged
- [x] PowerShell ports (`ledger-collab.ps1`, `ledger-collab-check.ps1`) parity
- [x] Docs: collaboration README event-format section; pointer from
  `core/schemas/ledger-schema.md`
- [x] Solo light path documented (collaboration README; edition prose can
  follow in a later release)
- [x] Runtime-verified: sh (Git Bash) and PowerShell, fresh project skeleton
