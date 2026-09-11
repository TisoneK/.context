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

## 2026-09-11 — Kai / glm-5.3-flash (Session 2, addendum)

- **Flaw:** `ledger-sync.ps1`'s office migration (`Migrate-OfficeLayout`, shipped in core 1.0.0 — my code, named per the repo rule) corrupts non-ASCII characters when it rewrites `history.conf`. Confirmed by reproduction: a UTF-8 `history.conf` whose comment holds an em-dash (`e2 80 94`) comes back with cp1252 mojibake (`â€"`) after `ledger-sync.ps1 migrate` on Windows PowerShell 5.1.
- **Symptom:** comments in the rewritten config are mojibake; the file stays *functional* (`office_size=20` parses fine, tools read only the keys), so it fails silently — grep-ability and byte-cleanliness of the config are lost, and any future non-ASCII content in the file gets mangled the same way.
- **Root cause:** `Get-Content -LiteralPath $hc` without `-Encoding UTF8` on Windows PowerShell 5.1 reads a BOM-less UTF-8 file in the system ANSI codepage (cp1252); the following `[IO.File]::WriteAllText(..., UTF8-no-BOM)` then re-encodes the already-mangled text as clean UTF-8 — corruption baked in. The 1.0.0 verification matrix missed it because the scratch `history.conf` used ASCII-only test data; the shipped template comment (`— read by ledger-history.`) is exactly the content that triggers it.
- **Suggested fix:** one line — read with `-Encoding UTF8` (or `[IO.File]::ReadAllText` with an explicit UTF-8 encoding) before the rewrite. Bundle into the in-flight **core 1.0.1 patch** (same release as the gate-verdict fix, owned by the other agent — do not duplicate). Class-level prevention for the same release: audit every `Get-Content`/`Set-Content` in the ps1 ports for missing explicit UTF-8 encoding — PS 5.1's ANSI defaults make every one of them a latent corruption site.
- **Status:** open — assigned to the 1.0.1 patch (another agent is working on it).
- **Correction (same session, before any other session reads this):** the version assignment above is wrong — this flaw is assigned to **core 1.0.2**, not 1.0.1. The other agent's in-flight 1.0.1 covers the gate-verdict fix only; the cp1252 encoding fix + the ps1 UTF-8 encoding audit ship as 1.0.2.

## 2026-09-11 — Noor / glm-5.3-flash (Session 3)

- **Flaw:** my own conduct, two misses, named per the repo's standing rule. (1) `git add .context_ledger/memory/collaboration/events/` staged the whole directory and committed Kai's (S002) just-completed note event under my commit — in a shared checkout, staging must be per-file. (2) my first `release` event cited only the product commits and carried no `paths`, so it matched no claim and `ledger-collab check` fails on it permanently — the state machine has no supersede path.
- **Symptom:** (1) a peer's event file published by someone else's commit. (2) the integration gate failed twice; the trail held a permanently-red event.
- **Root cause:** directory-granularity staging while sharing the checkout with a live peer; and I had not internalized that a release must either cite the claim ID or carry overlapping `paths`.
- **Suggested fix:** package: `ledger-collab emit release` could default `--paths` from the referenced claim (or refuse to emit a release that matches no claim) — the same condition that fails at integration would then fail at emit time, where it is cheap to fix. For the malformed event there is no in-protocol supersede; repaired by removing the never-referenced file with the supersession documented in the replacement release (git history keeps the original byte-for-byte).
- **Status:** open — conduct miss named; release-defaults-paths is a tooling suggestion for a future patch.
