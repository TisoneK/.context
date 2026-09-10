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
