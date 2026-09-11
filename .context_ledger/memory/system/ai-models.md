# Agent + Model Registry (update in place)

Which agents and models have worked on this repo — and what they've
shown they can and can't do here. Update your row each session (last
seen + session count); add a row only if this **(agent, model) pair** is
new. The Observations section is how the user learns which agent to hand
which task, and how agents learn a predecessor's blind spots (and verify
its work accordingly).

> **Update in place — do NOT append a duplicate.** This is not an
> append-only log. There is exactly one row per (agent, model) pair: to
> correct a count, model note, or date, **edit that row** — its prior value
> is safe in git history, so you lose nothing. Never add a second row for a
> pair that already exists (that is how a registry ends up with two rows
> and conflicting counts). Different models for the same agent are separate
> rows — that is expected, not a duplicate. `sh .context_ledger/core/bin/ledger-mem
> check` (Windows: the `.ps1`) flags a duplicated (agent, model) key.

<!-- TEMPLATE — one row per agent+model pair:
| <agent name> | <model id> | YYYY-MM-DD | YYYY-MM-DD | <count> |
-->

| Agent | Model | First seen | Last seen | Sessions |
|---|---|---|---|---|
| Ada | glm-5.3-flash | 2026-09-10 | 2026-09-10 | 1 |
| Noor | glm-5.3-flash | 2026-09-11 | 2026-09-11 | 1 |

## Observations

Concrete, evidence-based capabilities and limits — things demonstrated
in this repo's sessions, not marketing claims or self-assessment.
Update in place when a newer session contradicts an old observation.

<!-- TEMPLATE — one bullet per observation:
- **<agent> / <model>:** <what was observed — concrete and checkable, e.g. "Read tool truncates files >500 lines; needs offset/limit", "SSRF fix shipped with regression test, verified green"> (YYYY-MM-DD)
-->

## Observations

- **Ada / glm-5.3-flash:** strict-profile JSON (one "key": value per line, escaped body) round-trips exactly through pure POSIX sh readers (sed/awk) and Windows PowerShell `ConvertFrom-Json` alike; PowerShell gotcha surfaced and fixed — a bare `-or` between two command calls inside `if()` does not evaluate as two boolean results, so parenthesize or name the booleans (2026-09-10)
- **Noor / glm-5.3-flash:** verified on this machine that a PowerShell gate command whose pipeline has two external stages masks an earlier failure ($LASTEXITCODE ends up the tail's), while a `Tee-Object` tail preserves the tool's exit code — the parser-audit rule in ledger-gates.ps1 1.0.1 is built on that distinction; PS 5.1 `Parser::ParseInput/ParseFile` returns errors for 5.1-hostile syntax rather than throwing (2026-09-11)
