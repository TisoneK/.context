# .context Workflow — Quick Start

How to initialize a project (parent repo) with agent memory from the
protocol package, and how the two work together.

## The mental model

- **One protocol package repo** — `TisoneK/.context`, cloned at
  `~/Code/.context`. Holds the two protocol editions,
  the `context-skeleton/`, and the `roles/` overlays. You improve it
  once, over time.
- **Each project gets a `.context/` directory** committed inside it —
  bootstrapped from the package skeleton, then living its own life with
  that project. It is **not** a separate repo; it travels with the
  project's own pushes.

```text
~/Code/.context     ← the package (TisoneK/.context)
├── ai-engineering-protocol.md        cloud/sandbox edition
├── ai-engineering-protocol-local.md  local/IDE edition
├── context-skeleton/                 17-file stub tree (incl. SYNC.md)
└── roles/                            reviewer / security-auditor / docs-agent

~/Code/myproject                   ← any parent repo
└── .context/                         bootstrapped copy — the project's memory
```

## One-time, per machine

```bash
git clone https://github.com/TisoneK/.context.git ~/Code/.context
```

## Per project — initialize the parent repo + its memory

```bash
# 1. Your project repo (new or existing)
cd ~/Code && mkdir myproject && cd myproject && git init -b main
# (or just cd into an existing repo)

# 2. Bootstrap its memory from the package skeleton
cp -r ~/Code/.context/context-skeleton .context

# 3. Commit — .context/ is part of the project now
git add .context && git commit -m "chore(context): bootstrap .context/ directory"
git push   # once the project has a remote
```

Notes:
- `secrets/` inside `.context/` stays local automatically — its own
  `.gitignore` keeps values out of git. Everything else travels.
- You can skip step 2 and let the first agent session bootstrap it —
  the protocol's Step 3 covers that.
- Optionally pre-fill `.context/user/identity.md`, `user/preferences.md`,
  and `workflows/active.md`; otherwise the first session fills them
  from Pre-Flight.

## Per session — running an agent on the project

1. **Pick the edition** that matches the agent and fill its Pre-Flight
   for this project:
   - `ai-engineering-protocol-local.md` — Claude Code / Cursor / Copilot
     on your machine (uses your git credentials; no PAT).
   - `ai-engineering-protocol.md` — cloud/sandbox agents that clone the
     repo themselves (paste the PAT in chat, never in the file; rotate
     it after the session).
2. **Optionally add one role overlay** from `roles/` for a
   mission-scoped session — reviewer (read-only), security-auditor,
   docs-agent. No overlay = full-scope engineer. Where the role file
   and the edition conflict, the role file wins.
3. **Hand the agent the file(s).** It runs the loop on its own:

   ```text
   read .context/  →  work  →  update .context/  →  push
   (sessions, backlog,          (session entry, report,
    traps, decisions,            inefficiencies, learned
    your preferences)            preferences)
   ```

   Memory updates commit as `chore(context):`; review reports as
   `docs(review):`.

## How the two repos divide the work

| | Package repo (`TisoneK/.context`) | Project's `.context/` directory |
|---|---|---|
| Holds | Protocol editions, skeleton, roles | That project's living memory |
| Changes when | You improve the workflow | Every agent session on the project |
| Learnings about the **protocol** | flow back here | — |
| Learnings about the **project** | — | accumulate here |

- New projects always bootstrap from the latest skeleton.
- Already-bootstrapped projects keep working as-is — their `.context/`
  is data, not code. Back-port a new package feature (e.g. `secrets/`)
  only if you want it there.
- Any agent, on any machine, on any model, pulls the same project
  memory — that's the point.
