# Agent Sessions (append-only within the current group)

One entry per agent session in the **current group**, newest at the bottom.
Never edit or delete past entries — append corrections instead. This is not
append-only *forever*: when the group reaches `group_size` sessions (or a
milestone), `ledger-history close` consolidates these entries into
`.context_ledger/history/group-<NNN>.md` and starts a fresh group here. Closed
groups in `history/` and `archive/` are never read at session start.
Before closing, promote any open thread into its durable domain file — the
new group starts clean.

<!-- TEMPLATE — copy below the last entry and FILL IN every placeholder:
---
## YYYY-MM-DD — Session N
- **Agent:** <name> | **Model:** <model id> | **Platform:** <machine/sandbox + OS> | **Role:** <engineer, or overlay from .context_ledger/core/roles/> | **Core:** <version from .context_ledger/core/VERSION>
- **Task:** <what this session set out to do>
- **Commits:** <count> (<first-sha>..<last-sha>)
- **Outcome:** <done / partial / blocked — one line>
- **Open items:** <pointers into tasks/backlog.md, or "none">
- **Notes:** .context_ledger/memory/sessions/<date>-<N>/notes.md  (or "none")
- **Report:** .context_ledger/memory/reviews/YYYY-MM-DD-review.md
-->

## 2026-09-10 — Session 1
- **Agent:** Ada | **Model:** glm-5.3-flash | **Platform:** Windows 11 workstation (local, Git Bash) | **Role:** engineer | **Core:** 0.22.0
- **Task:** ship collaboration-events-as-JSON (schema v1, solo light path, sh+ps1), resolve the two-session release collision, self-host the ledger on this repo with the release-sync rule
- **Commits:** 6 (e84bdd1..0e8e7cc)
- **Outcome:** done — core 0.22.0 released; .context_ledger/ bootstrapped; first solo claim→release cycle validated through `ledger-collab check`
- **Open items:** none
- **Notes:** summary only
