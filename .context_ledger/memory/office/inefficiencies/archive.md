# Inefficiency Log — archive (verbatim moves from log.md)

Entries below were explicitly marked `RESOLVED` / `superseded` / fixed
in the live log and moved here verbatim (no edits), per the log's
pruning rule. Startup reads only the live log; this archive stays in
git, grep-able.

## 2026-09-11 — Kai / glm-5.3-flash
- **Problem:** shipped a PowerShell port with `&&` statement separators that parses on PowerShell 7 but dies on Windows PowerShell 5.1 (the fleet's default) — caught only because a parse check was added to the verification matrix.
- **Cost:** one fix cycle + a re-run of the manifest regen; would have been a broken tool for every 5.1 user if released.
- **Cause:** no automated syntax gate for the ps1 ports; 5.1 compatibility is a per-release manual concern.
- **Workaround / fix:** added a Parser::ParseFile syntax check to the session's verification routine; suggest packaging it as a `ledger-mem` check or a maintainer checklist line.
- **Prevent next time:** a `ps1-parse` maintenance check in the package (ParseFile over every bin/*.ps1) so a port that doesn't parse can't ship.
- **RESOLVED (2026-09-11, Noor / S003):** shipped in core 1.0.1 as part of `ledger-sync verify` — ParseFile over every `bin/*.ps1` and `sh -n` over every sh port, each edition checking what its host can run (commit 1ee0546). A port that cannot parse can no longer pass verify, so it cannot ship or self-host.
