# Session Summary (compressed history — entries are removable)

One compact entry per session, newest at the bottom. Unlike
`agents/sessions.md` (the formal registry, append-only forever), this
file is a **working summary**: entries may be removed when a session is
no longer useful, and older detail is expected to compress over time.

The purpose is **continuity, not archival completeness**. A future agent
should understand at a glance what important work happened recently,
what significant decisions were made, and where to find detail if needed.

Entries are separated by `---` so agents can parse them as discrete
records.

<!-- TEMPLATE — copy below the last entry:
---
- **YYYY-MM-DD — Session N** — <agent> / <model> — <one-line outcome>.
  <Key decision or discovery, if any.>
  Detail: .context_ledger/memory/sessions/YYYY-MM-DD-N/notes.md (or \"summary only\").
-->

<!-- GC GUIDANCE (not part of the template — remove this comment before committing):
- Keep all entries from the last ~10 sessions.
- Older entries: distill key facts into the durable logs (decisions,
  inefficiencies, backlog) if they haven't been promoted already, then
  remove the summary line. The compact entry in agents/sessions.md is
  the permanent record that the session happened.
- Never let SUMMARY.md become another giant history file — if it exceeds
  ~40 lines, it's time to compress.
- A removed summary line MUST have a corresponding permanent entry in
  agents/sessions.md — never delete the only record of a session.
-->

- **2026-09-10 — Session 1** — Ada / glm-5.3-flash — core 0.22.0 shipped (collab events as JSON + backlog closeout sweep); ledger self-hosted with the release-sync rule. First solo claim→release cycle validated on the new board. summary only.
- **2026-09-11 — Session 2** — Kai / glm-5.3-flash — office architecture shipped as core 1.0.0 (live memory/office/, verbatim freeze at close, permanent accomplishments records, during-sync migration, checkpoint nudge); self-hosted, repo memory grouped into the office; sh+ps1 verified e2e. summary only.
