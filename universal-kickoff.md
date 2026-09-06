# Universal Agent Kickoff — `.context/` Protocol Entry Point (Bootstrap)

> **Hand this file to the agent for a project's FIRST-EVER `.context/`
> session — and only that one.** It walks any agent through the
> bootstrap: get the protocol package on disk once, vendor it into the
> project as `.context/core/`, create the project's memory in
> `.context/memory/`, generate the in-repo entry points, push. After
> this session the project is **self-contained**: the protocol travels
> inside the repo, and no future session — local or cloud — needs the
> package, a package PAT, or this file.

> **Already bootstrapped? STOP — use the inbound kickoff instead.** If
> the project repo already contains `.context/kickoff.md`, switch to it
> now and follow it. If it contains `.context/` but no `kickoff.md` (or
> a flat pre-0.2.0 layout), this is a **migration**, not a bootstrap —
> follow `MIGRATION.md` in the package instead.

> **This copy may be STALE — hand over to the fresh one after Step 0.**
> This file travels as a copy (a Desktop file, a chat upload), and
> copies rot while the package moves on. Treat this copy as a
> **bootloader**: its only irreplaceable cargo is the Pre-Flight values
> below and Step 0 (get the package on disk). The moment Step 0
> completes, a fresh copy exists at `../context/universal-kickoff.md` —
> compare, and if they differ, **switch to the package's copy** for
> every step from Step 1 on, carrying over only your Pre-Flight values:
>
> ```bash
> diff <this-file> ../context/universal-kickoff.md >/dev/null \
>   && echo "copy is current — proceed" \
>   || echo "copy is STALE — follow ../context/universal-kickoff.md from Step 1 on"
> ```

You are joining a project as a senior software engineer. Your objective:
understand the project, follow the protocol, do good work, leave the
codebase and its `.context/` memory in a better state.

---

## Pre-Flight (USER FILLS IN COMPLETELY BEFORE STARTING)

> The agent reads this section once and never asks the user to clarify
> or supplement it. If a field is blank, the agent uses the documented
> default. Fill in everything you have an opinion on.

### Project

- **Project Name:** <PROJECT_NAME>
- **Project Repository URL:** https://github.com/<OWNER>/<REPO>.git
- **Is the project repo private?** <Yes / No>
- **Live Application (if available):** <LIVE_URL or N/A>
- **Local repo path (LOCAL agents only — the already-cloned working dir):** <e.g., /Users/you/Code/<REPO> — leave blank for cloud/sandbox agents>

### Git Identity

- **Name:** <GIT_NAME>
- **Email:** <GIT_EMAIL>

### Agent Identity (USER FILLS IN — AGENT COPIES, NEVER GUESSES)

> **The user fills in the model version.** The agent must never *guess*
> its own model — a guess propagates as wrong data across sessions.
> Precedence for recording the model: (1) if the user filled it in below,
> copy that verbatim; (2) else, if your own system prompt states your exact
> model ID, record that (it's a fact, not a guess); (3) else ask the user
> once in chat; (4) if still unknown, record `unknown` — never fabricate a
> version number. Note: many agents' system prompts do NOT state the model,
> so (2) often doesn't apply — don't infer from marketing names or your
> family (e.g. "Claude" ≠ a version).

- **Agent name:** <e.g., Super Z, Claude Code, GitHub Copilot>
- **Model:** <e.g., glm-5.2, claude-sonnet-4, gpt-5, deepseek-v4-flash-free>
- **Platform:** <e.g., Z.ai cloud sandbox, local Windows machine, GitHub Actions>

### Session Parameters

> Defaults are shown in brackets — change if you want something different.

- **Scope:** discovery + review + fix all safe issues _[default]_
- **Target:** general sweep _[default — scan everything, fix safe issues. Other values: `refactor <path>`, `fix <bug>`, `feature <description>`, `review <area>`, or free text.]_
- **Focus areas:** all _[default]_
- **Findings handling:** fix safe issues; flag architectural changes _[default]_
- **Push policy:** push to main directly after each commit _[default]_
- **Deliverable:** report in `.context/memory/reviews/` + chat summary _[default]_
- **Commit granularity:** one logical change per commit _[default]_

### GitHub PAT (CLOUD/SANDBOX AGENTS ONLY)

> **Privacy is per-repo.** The project repo and the package repo each
> declare their own mode — never assume one from the other. Cloud/sandbox
> agents need PAT access for **every** repo marked private — and for
> **every push, even to a public project repo**; local agents need none
> (the user's credentials cover both).
>
> **Recommended: ONE fine-grained PAT scoped to this workflow's private
> repos** — the project repo (Contents: Read and write), plus the package
> repo (Contents: Read-only) **for this bootstrap session only**. After
> bootstrap, the protocol lives inside the project: future cloud sessions
> need a PAT only for the project repo, never for the package again.
>
> **⚠️ DO NOT PUT PATs IN THIS FILE.** The file upload pipeline redacts
> secrets — if you paste one here, the agent receives
> `[REDACTED:github_token]` and cannot clone.
>
> **Instead:** Paste the PAT directly in your first chat message after
> uploading this file, **saying which repos it covers**:
>
> > "PAT (covers project + package): `github_pat_...`"
>
> The agent uses them as transient env vars and never writes them to any
> file. **Rotate the PAT(s) after the session ends.**

### Package Repository (where the protocol lives — needed THIS SESSION ONLY)

- **Package repo URL:** https://github.com/TisoneK/.context.git _[default — change if you use a fork/mirror]_
- **Is the package repo private?** <Yes / No> _[default **Yes** — the canonical `TisoneK/.context` is **private**: unauthenticated clones 404 (verified 2026-07-13). Don't trust this default blindly — visibility has changed before; the clone commands in Step 0 handle either case.]_

---

## The Model: Vendor Once, Self-Contained Forever

> **Read this before Step 0.** The protocol package is needed **on disk
> once**, in this bootstrap session. The bootstrap copies its `core/`
> tree INTO the project as `.context/core/` — versioned, checksummed,
> read-only — beside the project's own writable memory in
> `.context/memory/`:

| | Lives at | Owner | Sync |
|---|---|---|---|
| **Vendored protocol** | `<REPO>/.context/core/` | package | whole-tree, via `context-sync update` |
| **Project memory** | `<REPO>/.context/memory/` | project | never synced — yours forever |

After the bootstrap push, every future session — any agent type, any
machine — starts from `.context/kickoff.md` inside the repo and runs
entirely from the vendored core. The package repo is touched again only
to **update** core (`context-sync status/update`, any later session,
optional) or to back-port flaws. The package is NOT a submodule and is
never pushed to from a project session.

---

## How to use this file (two ways to set the Target)

1. **Pre-fill the Target field above** — set it once before uploading.
2. **Include a target description in your chat message** — the agent
   extracts it and it **overrides** the Pre-Flight Target. If the chat
   message is just "start," the Pre-Flight Target (default: general
   sweep) applies.

---

## Step 0 — Get What This Session Needs on Disk

### 0a. Identify your agent type

- **Local agent** — IDE-integrated (Claude Code, Cursor, GitHub Copilot,
  Continue, …). Runs on the developer's machine, uses the user's existing
  git credentials, and the project repo is **already cloned on disk**.
  → Do **Local — Step 0**. **Ignore every PAT / `GIT_TOKEN` instruction
  in this whole file** — they never apply to you.
- **Cloud/sandbox agent** — runs in an ephemeral sandbox, starts with
  **no repo on disk**, authenticates via a PAT. You need a PAT for
  **every push** (even to a public project repo) and for **every private
  clone** — if no PAT covering those arrived in chat, **ask for it now,
  before any clone attempt**. A missing credential is a missing input,
  not a permission question.
  → Do **Cloud/sandbox — Step 0**.

> **Unsure which you are?** Run `git remote get-url origin`. If it returns
> the Project Repository URL, you're already inside the repo — you're
> **local**. If there's no repo (empty workspace), you're **cloud/sandbox**.

### Local — Step 0

**0-L.1 — Confirm you're in the project repo (do NOT clone it).**
```bash
pwd                          # should be <LOCAL_REPO_PATH>; cd there if not
git remote get-url origin    # should match the Project Repository URL
git status                   # tree should be clean before you start
```
- **Never re-clone the project.** No PAT, ever. If a push later fails
  with an auth error, stop and tell the user — it's their machine
  config, not yours to fix. Don't set git identity unless
  `git config user.name` returns empty.

**0-L.2 — Get the package as a sibling (this session only).**
**Identify the package by its REMOTE URL, never by directory name** —
local clones exist under different names (`../context` is canonical;
legacy `../.context` occurs):

```bash
PKG=""
for d in ../context ../.context; do
  git -C "$d" remote get-url origin 2>/dev/null | grep -q "TisoneK/.context" \
    && PKG="$d" && break
done

if [ -n "$PKG" ]; then
  # Found — freshen it. A FAILED PULL IS NOT A MISSING PACKAGE:
  # use the on-disk copy as-is and note the stale pull in your session log.
  git -C "$PKG" pull --ff-only || echo "pull failed — continuing with on-disk copy at $PKG"
else
  git clone https://github.com/TisoneK/.context.git ../context && PKG=../context
fi
echo "package clone: $PKG"
```

**Never clone when a package clone already exists** — one find → one
decision → move on.

### Cloud/sandbox — Step 0

**0-C.1 — PAT(s) from chat, as env vars. Never into any file. Never echoed.**
```bash
export GIT_TOKEN='<from-chat>'        # project pushes (whole session)
export PKG_TOKEN="$GIT_TOKEN"         # or the separate package PAT, if provided that way
```

**0-C.2 — Clone the project repo.**
```bash
cd <workspace>
git clone "https://x-access-token:${GIT_TOKEN}@github.com/<OWNER>/<REPO>.git" <REPO>   # private
# public: git clone https://github.com/<OWNER>/<REPO>.git <REPO>
cd <REPO>
git remote set-url origin https://github.com/<OWNER>/<REPO>.git    # strip the token IMMEDIATELY
git config user.name "<GIT_NAME>" && git config user.email "<GIT_EMAIL>"
```

**0-C.3 — Clone the package (per ITS OWN privacy field), then drop its token.**
```bash
cd <workspace>
git clone "https://x-access-token:${PKG_TOKEN}@github.com/TisoneK/.context.git" context   # private (default)
# public fork/mirror: git clone https://github.com/<PKG_OWNER>/<PKG_REPO>.git context
git -C context remote set-url origin https://github.com/TisoneK/.context.git
unset PKG_TOKEN   # the package is read-only reference; after this bootstrap no session needs it again
                  # (GIT_TOKEN stays for the project's pushes — unset only at the protocol's final step)
cd <REPO>         # work from the project repo root from here on
```

### 0c. Verify + staleness handover

```bash
ls "$PKG"/core 2>/dev/null || ls ../context/core    # VERSION, rules/, schemas/, templates/, bin/
```

Diff the copy of this file you were handed against
`../context/universal-kickoff.md` (see the bootloader note at the top)
— if they differ, execute Steps 1–4 from the **package's** copy.

> **Two directories, don't conflate them:** `../context` (a sibling) is
> the package clone — this session's source; `./.context` (inside the
> project) is what you're about to create. After this session only the
> second one matters.

---

## Step 1 — Bootstrap `.context/` (Path A) or Hand Over (Path B)

### Path B first: `.context/` already exists

- Has `.context/kickoff.md` → **you're in the wrong file**: read
  `.context/kickoff.md` and follow it instead. Done here.
- Has `.context/` but flat (no `core/`+`memory/` zones) → **migration**,
  not bootstrap: follow `../context/MIGRATION.md`.

### Path A: `.context/` does not exist — bootstrap it

#### 1a. Run the bootstrapper

```bash
sh ../context/core/bin/context-sync bootstrap .
```

`bootstrap` is sh-only — on **Windows**, run this one step under Git Bash
or WSL. Every *later* session command (`verify`/`status`/`update`/
`rollback`/`lock`) has a native PowerShell port and needs no POSIX shell.

It vendors `core/` → `.context/core/`, copies the memory skeleton →
`.context/memory/`, seeds `.context/README.md` + `.context/kickoff.md`
+ root `AGENTS.md` + root `CLAUDE.md` (a pointer so Claude Code is routed
in) + `.context/.gitattributes` (LF policy), and writes `memory/core.lock`.
Verify (Windows: `.context/core/bin/context-sync.cmd verify`):

```bash
sh .context/core/bin/context-sync verify
ls .context/.git .context/core/core .context/memory/memory 2>/dev/null
# ANY output from the second line = a nested/double copy — rm -rf .context and redo 1a.
```

#### 1b. Fill in the initial memory

Using Pre-Flight (each file's HTML-comment template says how — don't
invent formats):

- **`.context/memory/user/identity.md`** — name, git identity, GitHub username, role, timezone
- **`.context/memory/user/preferences.md`** — seeded from Pre-Flight session parameters
- **`.context/memory/workflows/active.md`** — protocol **"by agent type", naming BOTH editions** (never just your own — see the template's comment), protocol location (vendored), package upstream URL, scope, push policy, deliverable
- **`.context/memory/system/environments.md`** — this machine/sandbox, with its "Identify by" line
- **`.context/memory/system/ai-models.md`** — this agent + model: first row
- **`.context/memory/tasks/current.md`** — this session's task
- **`.context/memory/agents/sessions.md`** — first session entry (include the core version)

If you record only your own edition in `workflows/active.md`, the next
agent of the other type inherits your platform's behavior — a local
agent on a cloud-bootstrapped repo starts doing PAT dances. Edition
choice belongs to the agent's type at session start, never to the file.

#### 1c. Fill the generated entry points

- **`.context/kickoff.md`** — fill Project Facts per its HTML-comment
  rules: facts you **verified on disk** (remote URL, default branch)
  beat Pre-Flight; session parameters stay out (they live in
  `workflows/active.md`); no secrets, ever.
- **`AGENTS.md`** (project root) — fill `<PROJECT_NAME>`. This is the
  canonical digest. Bootstrap already created a root `CLAUDE.md` pointer
  (Claude Code auto-loads it, not AGENTS.md). If the user's other tools read
  their own entrypoint, add a one-line "read AGENTS.md first" pointer there
  too — Copilot: `.github/copilot-instructions.md`, Cursor: `.cursor/rules`,
  Gemini: `GEMINI.md`.
- Placeholder scan (covers 1b too — run before committing):
  ```bash
  grep -rn "<PROJECT_NAME>\|<PROJECT_REPO_URL>\|<GIT_NAME>\|<GIT_EMAIL>\|<LIVE_URL" .context/ AGENTS.md CLAUDE.md
  # Hits allowed ONLY inside HTML template comments and symbolic token forms.
  ```

#### 1d. Commit and push the bootstrap

```bash
git add .context/ AGENTS.md CLAUDE.md
git commit -m "chore(context): bootstrap .context/ (core $(cat .context/core/VERSION))

Vendored protocol core + initial memory from TisoneK/.context.
Entry point for future sessions: .context/kickoff.md"
git pull --ff-only && git push origin main
# cloud/sandbox + private repo: re-add the token for the push, then strip it again
```

**Why push before starting the phases:** if the session dies during
Phase 1, the memory is already on remote — the next agent picks up
where this one left off, not from scratch.

---

## Step 2 — Read `.context/`, Step 3 — Load the Protocol, Step 4 — Follow It

From here the generated `.context/kickoff.md` — whose Entry Steps are
the canonical version of what follows — takes over:

1. **Read** `.context/README.md` (zone map), then the memory files in
   its listed order (sessions, tasks, logs, decisions, overrides,
   system, user).
2. **Load your edition from the vendored core, by YOUR agent type:**
   local → `.context/core/rules/ai-engineering-protocol-local.md`;
   cloud/sandbox → `.context/core/rules/ai-engineering-protocol.md`.
   Plus any role overlay from `.context/core/roles/`. Read it in full —
   it is the instruction set for this session.
3. **Follow it**: all steps, all phases, in order. Don't skip Phase 1
   because the task seems small. Don't ask permission for default next
   steps. Don't forget the Exit checklist — everything committed AND
   pushed, session logged, `tasks/current.md` cleared, PAT unset
   (cloud only), chat summary delivered.

---

## Don't

- **Don't start the project's server** unless the task requires it.
  "Start context workflow" means follow this protocol, not run the app.
- **Don't grep the codebase for "context"** to find the protocol — read
  `.context/` directly.
- **Don't write anything under `.context/core/`** — it's the vendored,
  checksummed protocol. Memory goes under `.context/memory/`.
- **Don't guess your model version.** Ask once or record `unknown`.
- **Don't skip Phase 1** because the task seems small.
- **Don't push to the package repo** — it's this session's read-only
  source, not your workspace.
- **Don't carry this file to the next session** — the project now has
  `.context/kickoff.md`; hand THAT to the next agent.

---

## Quick Reference

| If you need... | Look in... |
|---|---|
| The entry point for every future session | `<REPO>/.context/kickoff.md` (supersedes this file) |
| The protocol editions | `<REPO>/.context/core/rules/` |
| Role overlays | `<REPO>/.context/core/roles/` |
| The file/format spec | `<REPO>/.context/core/schemas/context-schema.md` |
| Core version / integrity / updates | `sh <REPO>/.context/core/bin/context-sync status|verify|update` |
| Prior agent sessions | `<REPO>/.context/memory/agents/sessions.md` |
| Open tasks | `<REPO>/.context/memory/tasks/backlog.md` |
| Known traps | `<REPO>/.context/memory/inefficiencies/log.md` |
| Protocol problems found | `<REPO>/.context/memory/flaws/log.md` |
| Architectural decisions | `<REPO>/.context/memory/plans/decisions.md` |
| Your environment's quirks | `<REPO>/.context/memory/system/environments.md` |
| User preferences | `<REPO>/.context/memory/user/preferences.md` |
| Secret values (never tracked) | `<REPO>/.context/memory/secrets/` |

---

## Final Note

This file is a **one-time bootloader** per project. It gets the package
on disk once, vendors the protocol into the project, and generates the
real entry points: `.context/kickoff.md` (the front door), `AGENTS.md`
(the digest for agents that auto-load root instructions), and `CLAUDE.md`
(a pointer to AGENTS.md so Claude Code, which auto-loads CLAUDE.md, doesn't
miss the protocol). From the next session on, *"Read `.context/kickoff.md`
and follow it"* is the entire kickoff — for any agent, on any machine, with
no package access at all.
