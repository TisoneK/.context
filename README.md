# .context_ledger — AI Engineering Protocol

A reusable protocol package for running AI agents against a codebase,
built around a **two-zone `.context_ledger/` directory** committed to every
project:

- **`.context_ledger/core/`** — this package's `core/` tree, **vendored** into
  the project: the protocol editions, roles, schemas, templates, and the
  `ledger-sync` tool. Read-only, version-stamped, checksummed. The
  protocol travels with the repo — after bootstrap, no session (local or
  cloud) needs this package, a clone, or a package PAT.
- **`.context_ledger/memory/`** — the project's living memory: sessions, tasks,
  decisions, friction logs, user preferences, machine records. Writable,
  project-owned, never touched by sync.

Every session starts by reading `.context_ledger/` and ends by updating
`memory/`, so any agent — any model, any machine — knows what every
prior agent did, what's open, what's decided, and what went wrong before.

## Contents

| Path | What it is |
|---|---|
| [`core/`](core/) | **The vendorable tree** — exactly what lands in each project as `.context_ledger/core/`. |
| [`core/rules/`](core/rules/) | The two protocol editions: [`ai-engineering-protocol-local.md`](core/rules/ai-engineering-protocol-local.md) (IDE agents — user's git credentials, no PAT) and [`ai-engineering-protocol.md`](core/rules/ai-engineering-protocol.md) (cloud/sandbox agents — clone + PAT). Selection is **by agent type at session start, never by memory** (Pitfall #43). |
| [`core/schemas/`](core/schemas/) | [`ledger-schema.md`](core/schemas/ledger-schema.md) — the **single source of truth** on every `.context_ledger/` file: zone, write mode, fact scope (project / agent-type / machine / agent-model / user), the overrides contract, the weak-agent translation layer, and the sync/fallback model. Plus a machine-readable [`ledger.schema.json`](core/schemas/ledger.schema.json). |
| [`core/templates/`](core/templates/) | What projects are generated from: the `memory/` skeleton, [`kickoff.md`](core/templates/kickoff.md) (the in-repo front door), [`ledger-README.md`](core/templates/ledger-README.md) (zone map), [`AGENTS.md`](core/templates/AGENTS.md) (root discovery digest for agents that never read a 900-line edition). |
| [`core/roles/`](core/roles/) | Role overlays — reviewer (read-only), security-auditor, docs-agent, feature-engineer. Engineer (full-scope) is the default, no overlay needed. |
| [`core/bin/ledger-sync`](core/bin/ledger-sync) | POSIX-sh tool: `status` (startup change detection), `verify` (checksums vs `MANIFEST.sha256`), `update` (semver-gated whole-tree core replacement — memory untouched), `rollback` (restore the last-known-good core from git history), `bootstrap` (initialize a project), `manifest` (release tool). |
| [`core/bin/ledger-sync.ps1`](core/bin/ledger-sync.ps1) | PowerShell port for **Windows** agents (no POSIX shell): the session commands `status` / `verify` / `update` / `rollback` / `lock`. Shares `MANIFEST.sha256` with the sh tool (identical hashes). `manifest` / `bootstrap` / `harvest` stay sh-only. A `.cmd` launcher sits beside every `.ps1` port and runs it with `-ExecutionPolicy Bypass`, so Windows agents need no policy setup. |
| [`core/bin/ledger-collab`](core/bin/ledger-collab) + [`ledger-collab.ps1`](core/bin/ledger-collab.ps1) | POSIX/PowerShell helpers for opt-in peer collaboration: atomically emit immutable events, inspect live overlap, and run the integration-readiness `check` gate. |
| [`core/bin/ledger-gates`](core/bin/ledger-gates) + [`ledger-gates.ps1`](core/bin/ledger-gates.ps1) | Explicit lifecycle gates: per-turn checkpoints, pre-commit, integration, and exit commands using project-owned `memory/workflows/gates.conf`. |
| [`core/VERSION`](core/VERSION) + [`core/CHANGELOG.md`](core/CHANGELOG.md) | Core semver + one entry per release with migration notes. |
| [`universal-kickoff.md`](universal-kickoff.md) | **One-time bootstrap bootloader** — hand to the agent for a project's first-ever session. It vendors core into the project and generates the real entry points; every later session starts from the project's own `.context_ledger/kickoff.md`. |
| [`MIGRATION.md`](MIGRATION.md) | Moving pre-0.2.0 projects (flat `.context_ledger/`, sibling-clone protocol) to the two-zone layout — one commit, zero data loss. |
| [`flaws/`](flaws/) | **Consolidated workflow flaws** — friction agents hit with the protocol/`.context_ledger/` system itself, back-ported from all projects. The source of truth for protocol improvements. |
| [`examples/localmind-review.md`](examples/localmind-review.md) | Example session deliverable — a real review report produced under the protocol. |
| [`QUICKSTART.md`](QUICKSTART.md) | The mental model + bootstrap steps. Start here if you're new. |
| [`MVP.md`](MVP.md) | Public-release plan + feature roadmap — the single home for advanced/future feature ideas. |

## Usage

1. **Bootstrap (once per project):** fill [`universal-kickoff.md`](universal-kickoff.md)'s
   Pre-Flight and hand it to any agent — or run it yourself:
   ```bash
   sh core/bin/ledger-sync bootstrap <path-to-project-repo>
   ```
2. **Every session after that:** tell any agent
   *"Read `.context_ledger/kickoff.md` and follow it."* It routes by agent
   type to the right edition inside the vendored core. Optionally add
   one role overlay from `core/roles/` — where the role file and the
   edition conflict, the role file wins.
3. **Core updates (optional, any later session):**
   `sh .context_ledger/core/bin/ledger-sync status` at session start reports
   drift; same-MAJOR updates apply with `update` (memory is never
   touched), MAJOR bumps wait for the user. Corrupt or hand-edited
   core? `verify` catches it, `rollback` restores the version recorded
   in `memory/core.lock`.

## Working on this repo (the package as the session's target)

When a session's task is to change the **package itself** — a new
feature, a protocol fix, a flaw back-port — the package IS that
session's project repo, and the normal session defaults apply in full:
one logical change per commit, push after each commit, no confirmation
prompts on default next steps. This applies even when the session was
started with a direct task in chat rather than a kickoff file. Friction
with the protocol found while doing package work goes straight into
[`flaws/log.md`](flaws/log.md).

**Maintainer discipline:** any change under `core/` must regenerate the
manifest in the same commit — `sh core/bin/ledger-sync manifest` — and
pass the package test suite — `sh tests/run-tests.sh` — and
release-worthy changes bump `core/VERSION` + add a `core/CHANGELOG.md`
entry (semver: spec/layout breaks = MAJOR, features = MINOR, wording =
PATCH). **One workstream at a time.** Sessions here share the
self-hosted `.context_ledger/` office (see below): check in, claim, and
coordinate there. If you find uncommitted files you did not author, that
is a live peer — stop and surface to the supervisor instead of working
around them, and leave the manifest regen to the last session to finish.

**Self-hosting: this repo runs its own vendored `.context_ledger/`.**
Sessions here work like any project's — check in on the roster, claim
scope, log the session. The vendored core tracks **releases, not dev
head**: when a release commit lands, the releasing session syncs the
ledger as its closing step — `sh .context_ledger/core/bin/ledger-sync
update core` (the source is this repo's own `core/`) — verifies, and
commits as `chore(ledger): self-host core <version>`. Between releases
the board deliberately runs the last release; dev head isn't protocol
until it ships. MAJOR bumps still require the user's go-ahead
(`update --major`).

**The boundary: a package session's output stops at the package push.**
Fixes reach projects through **their own** next sessions —
`ledger-sync update` for core, regeneration for generated files — or
through the user relaying it. The maintainer session never commits into
another project's `.context_ledger/`, however obvious the fix: those repos
have their own agents, their own session logs, and their own locks.
Fix the source; let the instances pull.

## Design rules (the short version)

- **Two zones, one direction:** core is replaced whole from the package
  and never hand-edited in a project; memory is project-owned and never
  synced. Protocol learnings flow project → `memory/office/flaws/log.md` →
  this repo → the next core release.
- **Append-only logs stay append-only** — `sessions.md`, both friction
  logs, `decisions.md`. Corrections are appended, never edited in.
  (`tasks/backlog.md` is the one live queue: open work only — delete a
  line when its item is done; history is the session log + git.)
- **No secrets in tracked files** — values live only in
  `memory/secrets/`, a self-gitignored local-only module.
- **Fact scoping beats contamination** — edition by agent type,
  environment blocks by "Identify by" match, credential flows
  cloud-only. The schema states the rules; Pitfall #43 enforces them.
- **`chore(ledger):`** for memory commits; **`docs(review):`** for
  reports.
- **Inefficiency logging is mandatory** — friction you absorb silently
  is friction the next agent hits blind.
- **Session data is disposable** — detailed session notes live in
  `memory/office/sessions/` and can be deleted when no longer useful; the
  permanent record is `agents/sessions.md`. Durable facts are promoted
  to their domain before disposal — permanent context must never depend
  exclusively on an individual session.
- **Collaboration is opt-in, and peers are coworkers, not rivals** —
  concurrent agents use isolated worktrees/branches and immutable
  one-file-per-event records under `memory/collaboration/events/`. The
  everyday move is an informal `note` (the office channel); the common
  lifecycle is `note` + `claim`/`release`. Only a genuine conflict (same
  paths, incompatible changes) escalates to evidence-based peer assessment
  and an agreement naming the best option and one owner.
- **Verify before trusting** — if `.context_ledger/` contradicts the codebase,
  the codebase wins; append a correction.
