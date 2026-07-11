# .context — AI Engineering Protocol

A reusable protocol package for running AI agents against a codebase, built
around a **`.context/` directory** — portable agent memory that is committed
to git and travels with the repo. Every session starts by reading it and ends
by updating it, so any agent (any model, any machine) knows what every prior
agent did, what's open, what's decided, and what went wrong before.

## Contents

| Path | What it is |
|---|---|
| [`ai-engineering-protocol.md`](ai-engineering-protocol.md) | **Cloud/sandbox edition** — for agents that clone the repo themselves and authenticate with a PAT. Generic template — fill Pre-Flight per project. |
| [`ai-engineering-protocol-local.md`](ai-engineering-protocol-local.md) | **Local agent edition** — for IDE-integrated agents (Claude Code, Cursor, Copilot) working on an already-cloned repo with the user's own git credentials. Generic template. |
| [`context-skeleton/`](context-skeleton/) | The 14-file stub tree for bootstrapping `.context/` in a target repo. Every file carries its entry template in an HTML comment. Includes the self-gitignored `secrets/` module. |
| [`roles/`](roles/) | **Role overlays** — small files that re-scope a base edition to a mission: reviewer (read-only), security-auditor, docs-agent. Engineer (full-scope) is the default, no overlay needed. |
| [`localmind-review.md`](localmind-review.md) | Example session deliverable — a real review report produced by an agent following the protocol (LocalMind, Session 2). |

## Usage

1. Fill in the **Pre-Flight** section of the edition that matches your agent
   (cloud or local) and hand the file to the agent as its instructions. To
   run a mission-scoped session, add one overlay from `roles/` — where the
   role file and the edition conflict, the role file wins.
2. The agent bootstraps the target repo's memory on first session:

   ```bash
   cp -r context-skeleton <repo>/.context
   ```

3. Every session thereafter reads `.context/` first (Step 3) and updates it
   last (Steps 15–17). The two editions share the same `.context/` spec, so
   cloud and local agents can alternate on the same repo coherently.

## Design rules (the short version)

- **Append-only logs stay append-only** — `sessions.md`, `inefficiencies/log.md`,
  `tasks/backlog.md`, `plans/decisions.md`. Corrections are appended, never edited in.
- **No secrets in tracked files** — `.context/` is committed to git; names and
  locations only. Values agents need live in `.context/secrets/`, a local-only
  module whose own `.gitignore` keeps it out of the repo — it never travels.
- **`chore(context):` commit prefix** for memory updates; review reports commit
  as `docs(review):`.
- **Inefficiency logging is mandatory** — friction you absorb silently is
  friction the next agent hits blind.
- **User corrections become memory** — standing preferences are recorded in
  `user/preferences.md` with provenance, so the user never gives the same
  correction twice.
- **Verify before trusting** — if `.context/` contradicts the codebase, the
  codebase wins; append a correction.
