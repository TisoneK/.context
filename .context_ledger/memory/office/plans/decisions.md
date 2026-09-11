# Architectural Decisions (append-only, ADR-style)

Decisions already made — future agents respect these rather than
relitigating them. To reverse one, append a new ADR that supersedes it.

<!-- TEMPLATE — copy below the last entry:
---
## ADR-N: <short title> (YYYY-MM-DD)
- **Status:** accepted | superseded by ADR-M
- **Context:** <what forced the decision>
- **Decision:** <what was decided>
- **Consequences:** <trade-offs accepted; what future agents must respect>
-->

## ADR-1: Collaboration events are immutable JSON documents, v1 (2026-09-10)
- **Status:** accepted — shipped in core 0.22.0
- **Context:** markdown frontmatter events had a `none` sentinel, CSV-in-string fields, no version marker on a durable trail, and no machine validation; the light path needed to work identically solo and in collaboration.
- **Decision:** one `<id>.json` per event per `collab-event.schema.json` v1, written in a strict profile (fixed key order, one key per line, UTF-8 no BOM) so POSIX-sh readers need no JSON dependency; legacy `.md` events stay readable forever. Full design: `designs/collab-events-json.md`.
- **Consequences:** writers must escape bodies (backslash/quote/CR/LF) and emit all 14 keys; the trail-level state machine stays in `ledger-collab check`; future format changes bump the `schema` field and branch readers.

## ADR-2: The ledger self-hosts; vendored core tracks releases, not dev head (2026-09-10)
- **Status:** accepted
- **Context:** the protocol's home repo had no coordination surface — two maintainer sessions collided mid-release (flaws/log.md 2026-09-10). The repo now runs its own vendored `.context_ledger/`.
- **Decision:** after a release commit lands, the releasing session syncs the vendored core as its closing step — `sh .context_ledger/core/bin/ledger-sync update core` (source = this repo's own `core/`), verify, commit as `chore(ledger): self-host core <version>`. Between releases the board runs the last release; dev head isn't protocol until it ships. MAJOR bumps need the user's go-ahead.
- **Consequences:** sessions here follow the same check-in/claim/log discipline as any project (README "Working on this repo"); the manifest regen belongs to the last session to finish; one workstream at a time, or worktrees + the collab ceremony.

## ADR-3: The memory layout is an office — one live, unnumbered, frozen verbatim at close (2026-09-11)
- **Status:** accepted — shipped in core 1.0.0
- **Context:** session grouping (0.13.0) kept the live group as flat paths and condensed it into `history/group-<NNN>.md` on close, resetting roster and registry; resolved-but-unpruned durable-log entries and stale domain files leaked across group boundaries, and nothing nudged a close. The supervisor specified the inversion directly: one live office, numbered only when archived, frozen whole ("even the rosters stay intact — no trimming"), a permanent record per office so its accomplishments are never forgotten, and old layouts grouped into an office during sync.
- **Decision:** the live office is the unnumbered directory `memory/office/` (everything session-produced: roster, registry, notes, tasks, plans, flaws, inefficiencies, reviews); durable files (workflows/, collaboration/, system/, user/, overrides/, core.lock, secrets/) stay at the memory root and never rotate. `ledger-history close` moves the directory verbatim to `history/office-<NNN>/` (number derived from the records — no state file), writes the permanent record `history/office-<NNN>.md`, and seeds a fresh office from templates. No implicit carryover: the closing session re-seeds open threads explicitly. `ledger-gates checkpoint` warns when the office is full. Legacy flat layouts migrate during `update`/`migrate`. Full design: `designs/office-architecture.md`.
- **Consequences:** a new office cannot be misdirected by a previous office's leftovers — at the cost of ADRs and open flaws leaving the startup read at close (re-seeded only if still relevant; the permanent record is the bridge). Close is deliberate session work, not automation. Breaking layout change → MAJOR; every install migrates via `update --major`.

## ADR-4: Session reports are specified by voice, not by a mandated skeleton (2026-09-11)
- **Status:** accepted — shipped in core 1.0.4
- **Context:** every session report had to follow Executive Summary → Discovery Phase → Baseline Health → Findings → Fixes Applied → Open Items → Recommended Next Steps. The maintainer flagged the output as too complicated and robotic for the person who reads it; the skeleton optimized for archiving, not reading.
- **Decision:** Step 13 (both editions), `reviews/README.md`, and the feature-engineer overlay now specify the report's voice — plain sentences for the project's owner, what happened first, no form-speak headings — with a suggested flow (what happened → found → changed → still open → next) that sessions may reshape. A clean review is one plain line. The feature report keeps its substance list (design decisions, verified vs. not verified, open items).
- **Consequences:** reports will vary in shape between sessions (the `reviews/README.md` naming rules are unchanged, so files still sort and scan); "read the most recent report fully" remains how a session picks up prior work; severity labels survive only where a finding carries one.
