# Flaws Log (append-only — flows to the protocol package)

Friction caused by the `.context_ledger/` system or the protocol itself. See
`README.md` in this directory for the split between `flaws/` and
`inefficiencies/`.

Append-only, but prunable to cold storage: once an entry is explicitly
marked `RESOLVED` / `superseded` / fixed, move it **verbatim** into
`archive.md` in this directory so startup reads only the live entries.
`ledger-mem prune` reports which entries are archive-eligible (`--list`
names them); age alone never makes an entry eligible — an unresolved flaw
stays here as a live trap.

<!-- TEMPLATE — copy below the last entry:
---
## YYYY-MM-DD — <agent> / <model> (Session N)

- **Flaw:** <what in the protocol or .context_ledger/ system didn't work>
- **Symptom:** <what happened to the agent — the observable friction>
- **Root cause:** <why the protocol/.context_ledger/ let this happen>
- **Suggested fix:** <concrete change to the package — a step, a pitfall,
  a template, a rule>
- **Status:** open | fixed in package <commit-sha or date>
-->

## 2026-09-11 — Kai / glm-5.3-flash (Session 2)

- **Flaw:** `ledger-gates.ps1`'s gate verdict can clear a red gate — reported by a fleet project (Asha, S467, flaw reported upstream 2026-09-11) and confirmed here by reading `core/bin/ledger-gates.ps1` `Run-One` (lines 65–82).
- **Symptom:** a gated command whose failing tool is piped into a succeeding stdout consumer (e.g. `ci-check.sh 2>&1 | tee out.txt`) reports FAILED text but exits 0: `$LASTEXITCODE` after the pipeline is the *last* native command's (tee = 0), and `$?` follows it, so the gate passes. Silent failures still fail correctly, which is why some gate failures bite and others don't.
- **Root cause:** `Run-One` trusts `$LASTEXITCODE`/`$?` from the whole scriptblock; PowerShell only surfaces the pipeline tail's status, not every command's. Pre-existing — present before core 1.0.0 (not a regression from the office work; the 1.0.0 gate change was the checkpoint notice only).
- **Suggested fix:** run the gated text via an explicit subshell/`cmd /c` wrapper that propagates the real exit code, or fail if `$LASTEXITCODE` is non-null-and-nonzero OR `$?` is false AND reject compound commands whose last pipeline stage is not the tool under test; add a package test: a gated `failing-cmd | tee` must fail the gate. Until fixed, projects should treat gate stdout as the verdict, never rc alone.
- **Status:** open — fix upstream as core 1.0.1 (PATCH; tooling correctness).

## 2026-09-11 — Kai / glm-5.3-flash (Session 2)

- **Flaw:** my own conduct — the session never set `office/tasks/current.md` at session start (protocol Step 3) while shipping the protocol; found at closeout when the file was still idle. Also late: the check-in happened only after the user prompted work to begin.
- **Symptom:** for the whole session the board said no task was in progress while a MAJOR release was underway — a peer or crashed-session check would have read the office as idle.
- **Root cause:** jumped from the user's design questions straight into plan mode and implementation; treated the kickoff's Step 2/3 ordering as satisfied because memory had been read.
- **Suggested fix:** package: the pre-commit/exit gates could warn (not block) when `tasks/current.md` was never written during a session whose commits exist. Habit: set current.md immediately after the check-in push, before any plan-mode work.
- **Status:** open — conduct miss, named per the repo's standing rule; tooling suggestion for a future patch.
