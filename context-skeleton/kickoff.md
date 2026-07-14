# Project Kickoff — `.context/` Workflow Entry Point (Inbound)

<!-- GENERATED AT BOOTSTRAP — the universal kickoff's Step 1c fills this in.
This file is DATA (project-owned, never overwritten by structural sync).

Generation rules for the bootstrapping agent:
1. Fill every <PLACEHOLDER> in "Project Facts" from the external kickoff's
   Pre-Flight + what you verified on disk (git remote, default branch).
   Facts you verified beat facts the user typed — record what's true.
2. Do NOT copy session parameters here — they live in workflows/active.md
   (single source of truth). This file only points at them.
3. Do NOT put secrets, PATs, or tokens anywhere in this file. Ever.
4. Delete nothing else — the Entry Steps below are pre-written and correct
   for every post-bootstrap session. They are not placeholders.
5. Keep facts current in later sessions: if a fact changes (repo renamed,
   new default branch, live URL added), update it in place and note the
   change in your session entry.
-->

> **This is the project's own kickoff file.** It was generated during the
> first `.context/` session and supersedes the external universal kickoff
> for this repo — no more carrying a copy around. To start a session,
> point any agent here:
>
> - **Local agent** (already inside the repo): *"Read `.context/kickoff.md`
>   and follow it."* Add a target description in the same message if you
>   have one.
> - **Cloud/sandbox agent** (empty workspace): *"Clone
>   `<PROJECT_REPO_URL>`, read `.context/kickoff.md`, follow it."* If the
>   repo is private, paste the PAT in that same chat message — never into
>   any file.

---

## Project Facts (generated — keep current)

- **Project name:** <PROJECT_NAME>
- **Project repository URL:** <PROJECT_REPO_URL>
- **Private repo:** <Yes / No>
- **Default branch:** <main>
- **Live application:** <LIVE_URL or N/A>
- **Git identity:** <GIT_NAME> `<GIT_EMAIL>`
- **Package repo (the protocol):** https://github.com/TisoneK/.context.git — public, no PAT
- **Protocol edition:** local agents → `ai-engineering-protocol-local.md`; cloud/sandbox agents → `ai-engineering-protocol.md`

## Session Parameters

Standing defaults live in [`workflows/active.md`](workflows/active.md) —
scope, target, push policy, deliverable, commit style. **A target in the
user's chat message overrides the standing Target.** If the chat message
is just "start," use the standing Target.

**Agent identity:** never guess your model version. If your system prompt
states the exact model ID, record that; otherwise ask the user once, or
record `unknown`.

---

## Entry Steps (every session after bootstrap)

`.context/` already exists in this repo — there is no bootstrap path here.
Every session is a **sync** session.

### Step 0 — Get both repos on disk

**Local agent** — the project repo is your cwd (never re-clone it). Get
the package as a sibling:

```bash
git remote get-url origin        # confirm it matches the Project repository URL
# Package repo — clone as a sibling, or freshen if already there:
[ -d ../.context ] && git -C ../.context pull --ff-only \
  || git clone https://github.com/TisoneK/.context.git ../.context
```

No PAT, ever — your pushes use the user's existing credentials. If a push
fails with an auth error, stop and tell the user.

**Cloud/sandbox agent** — clone both into the workspace:

```bash
# Project repo (PAT from chat if private — strip it from .git/config right after):
git clone <PROJECT_REPO_URL_WITH_TOKEN_IF_PRIVATE> <REPO> && cd <REPO>
git remote set-url origin <PROJECT_REPO_URL>
git config user.name "<GIT_NAME>" && git config user.email "<GIT_EMAIL>"
# Package repo (public):
git clone https://github.com/TisoneK/.context.git ../.context
```

Keep `GIT_TOKEN` as an env var for the session's pushes; unset it only at
the protocol's final step. Never write it to any file.

### Step 1 — Sync

```bash
git pull --ff-only
```

If the pull fails (diverged) or the tree has changes you didn't make,
**stop and report** — don't stash or discard someone else's work. Then
sync structural files from the package skeleton per [`SYNC.md`](SYNC.md)
(add missing, update differing; never touch data files).

### Step 2 — Read `.context/` (this directory)

In order: `README.md` → `workflows/active.md` → `agents/sessions.md`
(last 3–5 entries) → `tasks/current.md` → `tasks/backlog.md` →
`inefficiencies/log.md` → `flaws/log.md` → `plans/decisions.md` →
`system/` → `user/` → note what's in `secrets/` (never print values).

### Step 3 — Load the protocol

Read the edition named in `workflows/active.md` from the package clone
on disk — `../.context/ai-engineering-protocol-local.md` (local) or
`../.context/ai-engineering-protocol.md` (cloud/sandbox) — plus any role
overlay from `../.context/roles/`. Read it in full; it is the instruction
set for this session.

### Step 4 — Follow the protocol

All 19 steps, all 4 phases, in order. Don't skip Phase 1 because the task
seems small. Don't forget the Exit checklist: everything committed and
pushed, session logged, `tasks/current.md` cleared, chat summary
delivered.

---

## If this file is stale or missing

The template lives in the package at `context-skeleton/kickoff.md`.
Regenerate by copying that template and filling **Project Facts** from
this directory's own memory (`user/identity.md`, `workflows/active.md`,
`git remote get-url origin`). Commit as
`chore(context): regenerate kickoff.md`.
