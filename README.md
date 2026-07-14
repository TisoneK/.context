# .context — AI Engineering Protocol

A reusable protocol package for running AI agents against a codebase, built
around a **`.context/` directory** — portable agent memory that is committed
to git and travels with the repo. Every session starts by reading it and ends
by updating it, so any agent (any model, any machine) knows what every prior
agent did, what's open, what's decided, and what went wrong before.

## Contents

| Path | What it is |
|---|---|
| [`universal-kickoff.md`](universal-kickoff.md) | **First-session entry point — hand this to the agent once per project.** Fill its Pre-Flight and it walks any agent through the door: get both repos on disk, bootstrap `.context/`, load the matching edition, run the protocol. Step 0 branches on agent type (local IDE vs cloud/sandbox), so a local agent never re-clones the repo or touches a PAT. The first session generates `.context/kickoff.md` **inside the project** (the inbound kickoff, pre-filled with the project's facts) — every later session starts from that file instead. Start here. |
| [`ai-engineering-protocol.md`](ai-engineering-protocol.md) | **Cloud/sandbox edition** — for agents that clone the repo themselves and authenticate with a PAT. Generic template — fill Pre-Flight per project. |
| [`ai-engineering-protocol-local.md`](ai-engineering-protocol-local.md) | **Local agent edition** — for IDE-integrated agents (Claude Code, Cursor, Copilot) working on an already-cloned repo with the user's own git credentials. Generic template. |
| [`context-skeleton/`](context-skeleton/) | The 18-file stub tree for bootstrapping `.context/` in a target repo. Every file carries its entry template in an HTML comment. Includes the self-gitignored `secrets/` module, the `flaws/` workflow-friction log, `SYNC.md` (the structural-vs-data sync manifest), and `kickoff.md` (the inbound-kickoff template — filled at bootstrap, entry point for all future sessions). |
| [`roles/`](roles/) | **Role overlays** — small files that re-scope a base edition to a mission: reviewer (read-only), security-auditor, docs-agent. Engineer (full-scope) is the default, no overlay needed. |
| [`flaws/`](flaws/) | **Consolidated workflow flaws** — friction agents hit with the protocol/`.context/` system itself, back-ported from all projects using this package. The source of truth for protocol improvements. |
| [`examples/localmind-review.md`](examples/localmind-review.md) | Example session deliverable — a real review report produced by an agent following the protocol (LocalMind, Session 2). |
| [`QUICKSTART.md`](QUICKSTART.md) | The two-repo mental model + bootstrap steps — how to initialize a project with `.context/` memory from this package. Start here if you're new. |

## Usage

1. Fill in the **Pre-Flight** section of [`universal-kickoff.md`](universal-kickoff.md)
   (the recommended entry point — it routes local vs cloud/sandbox agents and
   hands off to the right edition), or of the specific edition that matches
   your agent, and hand the file to the agent as its instructions. To run a
   mission-scoped session, add one overlay from `roles/` — where the role file
   and the edition conflict, the role file wins.
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
- **Structure syncs from the package; data never does** — `README.md`/`.gitignore`
  files (and `SYNC.md`) are package-owned structure an agent reconciles against
  `context-skeleton/` at session start; every other `.context/` file is
  project-owned data that sync never overwrites. See `context-skeleton/SYNC.md`.
