# Context Ledger Workflow — Quick Start

How to give a project persistent agent memory + a vendored protocol,
and how the pieces fit.

## The mental model

- **One protocol package repo** — `TisoneK/context-ledger`, cloned at
  `~/Code/context-ledger`. Its [`core/`](core/) tree is the product: editions,
  roles, schemas, templates, the `ledger-sync` tool. You improve it
  once, over time.
- **Each project carries `.context_ledger/`** with two zones: `core/` (a
  vendored, versioned copy of the package's core — read-only) and
  `memory/` (that project's living memory — writable, never synced).
  It is **not** a separate repo and **not** a submodule; it travels
  with the project's own pushes.

```text
~/Code/context-ledger              ← the package (TisoneK/context-ledger)
├── core/                             the vendorable tree
│   ├── VERSION · CHANGELOG.md · MANIFEST.sha256
│   ├── rules/ · roles/ · schemas/ · templates/ · bin/ledger-sync
├── universal-kickoff.md              one-time bootstrap bootloader
└── MIGRATION.md · MVP.md · flaws/    package-dev files (never vendored)

~/Code/myproject                   ← any project repo
├── AGENTS.md                         generated digest (auto-read by many tools)
└── .context_ledger/
    ├── README.md · kickoff.md        zone map + the front door
    ├── core/                         vendored protocol  (read-only)
    └── memory/                       project memory      (writable)
```

**The point:** after bootstrap, a project is self-contained. Any agent,
on any machine, cloud or local, runs entirely from the repo — no
package clone, no package PAT, no network fetch of the protocol.

## One-time, per machine (maintainer/bootstrapper only)

```bash
git clone https://github.com/TisoneK/context-ledger.git ~/Code/context-ledger
```

The package repo is **public** — bootstrap needs no token for it.
Only bootstrap (and optional core updates) ever touch it.

## Per project — bootstrap (once)

```bash
cd ~/Code/myproject        # a git repo (new or existing)
sh ~/Code/context-ledger/core/bin/ledger-sync bootstrap .
git add .context_ledger AGENTS.md
git commit -m "chore(ledger): bootstrap .context_ledger/ (core $(cat .context_ledger/core/VERSION))"
git push
```

Or hand [`universal-kickoff.md`](universal-kickoff.md) (Pre-Flight
filled) to any agent and let it do this plus fill the initial memory —
identity, preferences, workflow parameters, first session entry, the
kickoff's Project Facts, and `AGENTS.md`'s project name.

## Per session — running an agent on the project

> Tell the agent: **"Read `.context_ledger/kickoff.md` and follow it."**
> Add a target in the same message if you have one.

That file routes the agent by its own type:

```text
read .context_ledger/README.md (zones)  →  ledger-sync verify/status (core health)
→  read memory/ (sessions, tasks, logs, decisions, overrides, prefs)
→  load .context_ledger/core/rules/<your-type's edition> (+ role overlay)
→  work  →  update memory/  →  push
```

- Memory updates commit as `chore(ledger):`; reports as `docs(review):`.
- Cloud/sandbox agents need a PAT **for the project repo only** (pushes,
  private clone). Local agents need none.
- Weak agents that never open the full edition still get the floor:
  `AGENTS.md` at the repo root carries the zones, the entry point, and
  the ten condensed binding rules.

## Updating a project's core (optional, any later session)

```bash
sh .context_ledger/core/bin/ledger-sync status    # drift check at session start
sh .context_ledger/core/bin/ledger-sync update    # same-MAJOR: applies; MAJOR: asks for --major
```

On Windows, use the `.cmd` launchers (same commands; each runs its `.ps1`
port with `-ExecutionPolicy Bypass`, so no policy setup is needed):

```powershell
.context_ledger/core/bin/ledger-sync.cmd status
.context_ledger/core/bin/ledger-sync.cmd update
```

Updates replace `core/` as a whole and never touch `memory/` — local
customizations (overrides, preferences, logs) survive every bump. If
core ever fails `verify` (hand-edit, corruption), `rollback` restores
the last-known-good version recorded in `memory/core.lock`.

Projects bootstrapped before 0.2.0 (flat `.context_ledger/`, sibling-clone
protocol): see [`MIGRATION.md`](MIGRATION.md).

## How the package and a project divide the work

| | Package repo (`TisoneK/context-ledger`) | Project's `.context_ledger/` |
|---|---|---|
| Holds | The core source: editions, schemas, templates, roles, tool | Vendored core copy + that project's memory |
| Changes when | You improve the workflow (→ new core version) | Every agent session on the project |
| Learnings about the **protocol** | land here (from projects' `flaws/log.md`) | logged in `memory/office/flaws/log.md`, flow here |
| Learnings about the **project** | — | accumulate in `memory/`, forever |
