# Active Workflow (overwrite when the workflow changes)

The workflow currently in force for this repo — which protocol edition
agents follow and the standing session parameters. Update only when the
user changes the rules; note the change in your session entry.

- **Protocol:** by agent type — local agents → .context_ledger/core/rules/ai-engineering-protocol-local.md; cloud/sandbox agents → .context_ledger/core/rules/ai-engineering-protocol.md
- **Protocol location:** on disk — vendored in `.context_ledger/core/` (no network fetch needed; version in `.context_ledger/core/VERSION`, last verified in `memory/core.lock`)
- **Package upstream (for flaw back-ports + core updates):** https://github.com/TisoneK/context-ledger.git — this repo **is** the package; self-hosted
- **Since:** 2026-09-10
- **Default role:** engineer — maintainer sessions work on the package itself; see README "Working on this repo"
- **Scope:** discovery + review + fix all safe issues
- **Target:** general sweep unless the user's chat message names a task
- **Focus areas:** all — protocol spec, tools (sh + ps1 parity), templates, docs
- **Findings handling:** fix safe, flag architectural; protocol friction → flaws/log.md
- **Push policy:** push to main directly after each commit
- **Commit style:** Conventional Commits; chore(ledger): for .context_ledger/ files
- **Commit granularity:** one logical change per commit
- **Deliverable:** chat summary + memory updates; reviews to memory/reviews/ when the task is a review
- **Gates:** .context_ledger/memory/workflows/gates.conf — checkpoint before each next action; pre-commit, integration, and exit gates are mandatory
- **Self-hosting:** the vendored core tracks releases, not dev head — after a release commit, run `sh .context_ledger/core/bin/ledger-sync update core` + commit (see README "Working on this repo")
