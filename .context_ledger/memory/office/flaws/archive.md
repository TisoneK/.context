# Flaws Log — archive (verbatim moves from log.md)

Entries below were explicitly marked `RESOLVED` / fixed in the live log
and moved here verbatim (no edits), per the log's pruning rule. Startup
reads only the live log; this archive stays in git, grep-able.

## 2026-09-11 — Kai / glm-5.3-flash (Session 2)

- **Flaw:** `ledger-gates.ps1`'s gate verdict can clear a red gate — reported by a fleet project (Asha, S467, flaw reported upstream 2026-09-11) and confirmed here by reading `core/bin/ledger-gates.ps1` `Run-One` (lines 65–82).
- **Symptom:** a gated command whose failing tool is piped into a succeeding stdout consumer (e.g. `ci-check.sh 2>&1 | tee out.txt`) reports FAILED text but exits 0: `$LASTEXITCODE` after the pipeline is the *last* native command's (tee = 0), and `$?` follows it, so the gate passes. Silent failures still fail correctly, which is why some gate failures bite and others don't.
- **Root cause:** `Run-One` trusts `$LASTEXITCODE`/`$?` from the whole scriptblock; PowerShell only surfaces the pipeline tail's status, not every command's. Pre-existing — present before core 1.0.0 (not a regression from the office work; the 1.0.0 gate change was the checkpoint notice only).
- **Suggested fix:** run the gated text via an explicit subshell/`cmd /c` wrapper that propagates the real exit code, or fail if `$LASTEXITCODE` is non-null-and-nonzero OR `$?` is false AND reject compound commands whose last pipeline stage is not the tool under test; add a package test: a gated `failing-cmd | tee` must fail the gate. Until fixed, projects should treat gate stdout as the verdict, never rc alone.
- **FIXED (2026-09-11, Noor / S003):** shipped in core 1.0.1 (commits 8e5a8a6 fix, c97418d release) with the package test the entry asked for (`tests/run-tests.sh`, 11/11 green across both editions). sh edition: gated commands run under `set -o pipefail` where the shell (or a bash on PATH) supports it; on a shell without pipefail a gated top-level pipeline is rejected with a fix-it message instead of silently passing. PowerShell edition: gated text is parser-audited first — a pipeline with two or more external stages (or an unresolvable one) is rejected; at most one external stage runs, and the verdict fails on the exit code OR `$?` — either signal. The "treat gate stdout as the verdict" workaround is retired; the rc is the verdict again.
