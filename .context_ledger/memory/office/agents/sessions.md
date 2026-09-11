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

## 2026-09-11 — Session 2
- **Agent:** Kai | **Model:** glm-5.3-flash | **Platform:** Windows 11 workstation (local, Git Bash) | **Role:** engineer | **Core:** 0.22.0 → 1.0.0
- **Task:** office architecture (major): live unnumbered memory/office/, verbatim freeze at close, permanent accomplishments records, during-sync migration of flat layouts, full-office checkpoint nudge
- **Commits:** 6 (089a423..b5bbbf9)
- **Outcome:** done — core 1.0.0 released and self-hosted (repo memory grouped into the live office); sh+ps1 parity verified end-to-end on scratch projects (migration, close, roll, gc, mem, gates); 4 holes found and closed in-session
- **Open items:** none
- **Notes:** summary only
- **Addendum (re-check-in after clock-out, same session):** supervisor confirmed the Windows migration port wrote `history.conf` as cp1252, corrupting em-dashes — reproduced locally (`e2 80 94` → mojibake; keys still parse, so it fails silently) and logged in flaws/log.md, assigned to **core 1.0.2** (the other agent's in-flight 1.0.1 covers the gate-verdict fix only). One mishap named per the repo rule: the first addendum edit anchored inside Session 1's entry and briefly swallowed the Session 2 header — caught on read-back and repaired in the same session; Session 1 is byte-identical to its committed state again.
- **Addendum 2 (re-check-in after 1.0.1 landed):** shipped core 1.0.2 — the ps1 UTF-8 encoding audit (27 `Get-Content` sites explicit, `Write-Lock` byte-identical to sh via `[char]0x2014`, rename sweep UTF-8) with 3 new regressions in tests/run-tests.sh (14/14). Found and fixed en route: PS 5.1 *parses* BOM-less ps1 source as cp1252, so a non-ASCII literal in ps1 source double-encodes — ps1 string literals stay ASCII. Also cleaned up: my earlier `git add .context_ledger/memory/` had swept Noor's uncommitted leftover roster row into my closeout commit (staging flaw logged, her stale row removed); completed her gate-flaw move to flaws/archive.md (archive had the copy, active log kept the original). Commits afc5384 (fix), bf13a9a (release), 171fa17 (self-host) + closeout.

## 2026-09-11 — Session 3
- **Agent:** Noor | **Model:** glm-5.3-flash | **Platform:** Windows 11 workstation (local, Git Bash) | **Role:** engineer | **Core:** 1.0.0 → 1.0.1
- **Task:** core 1.0.1 (PATCH): gate-verdict fix — a gated `failing-cmd | tee` used to pass (sh+ps1) — with a package test suite; port parse checks as a permanent verify step
- **Commits:** 9 (3c2519c..3e08436)
- **Outcome:** done — core 1.0.1 released and self-hosted; tests/run-tests.sh 11/11 green across both editions; verify now refuses a core whose ports cannot parse
- **Open items:** none — fleet go-aheads for the 0.x→1.0.x office migration land on 1.0.1 via each project's own `ledger-sync update --major` (encoding fixes follow as Kai's 1.0.2)
- **Notes:** summary only
- **Collab:** session core-1.0.1 alongside Kai (S002, live in office); claim 20260911T100010Z-Noor-40bcd8d5 → release 20260911T115118Z-Noor-148d202f
