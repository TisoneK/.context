# Inefficiency Log (append-only, mandatory)

Every session appends one block — honestly. Friction you absorb silently
is friction the next agent hits blind. "None this session" is valid only
if literally nothing slowed you down.

Most inefficiencies are project-local (an environment quirk, a one-off
cost) and stay here. When one is actually **protocol-level** — the core
workflow itself made you slower and every project would hit it — mark it
`Upstream: candidate`. `ledger-sync harvest` collects those (and open
`flaws/`) into the package for an upstream fix. Unmarked entries are
never harvested.

Append-only, but prunable to cold storage: once an entry is explicitly
marked `RESOLVED` / `superseded` / fixed, move it **verbatim** into
`archive.md` in this directory so startup reads only the live entries.
`ledger-mem prune` reports which entries are archive-eligible; age alone
never makes an entry eligible.

<!-- TEMPLATE — copy below the last entry:
---
## YYYY-MM-DD — <agent> / <model>
- **Problem:** <what went wrong or was slower than it should be>
- **Cost:** <rough time/effort wasted>
- **Cause:** <root cause if known>
- **Workaround / fix:** <what worked, or "unresolved">
- **Prevent next time:** <protocol/context change that would have avoided it>
- **Upstream:** candidate  ← add this line ONLY for protocol-level friction
  worth a core fix; omit entirely for project-local friction.
-->

## 2026-09-11 — Kai / glm-5.3-flash
- **Problem:** shipped a PowerShell port with `&&` statement separators that parses on PowerShell 7 but dies on Windows PowerShell 5.1 (the fleet's default) — caught only because a parse check was added to the verification matrix.
- **Cost:** one fix cycle + a re-run of the manifest regen; would have been a broken tool for every 5.1 user if released.
- **Cause:** no automated syntax gate for the ps1 ports; 5.1 compatibility is a per-release manual concern.
- **Workaround / fix:** added a Parser::ParseFile syntax check to the session's verification routine; suggest packaging it as a `ledger-mem` check or a maintainer checklist line.
- **Prevent next time:** a `ps1-parse` maintenance check in the package (ParseFile over every bin/*.ps1) so a port that doesn't parse can't ship.
