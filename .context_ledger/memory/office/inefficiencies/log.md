# Inefficiency Log (append-only, mandatory)

Every session appends one block — honestly. Friction you absorb silently
is friction the next agent hits blind. "None this session" is valid only
if literally nothing slowed you down.

Most inefficiencies are project-local (an environment quirk, a one-off
cost) and stay here. When one is actually **protocol-level** — the core
workflow itself made you slower and every project would hit it — mark it
`Upstream: candidate`. `ledger-sync harvest` collects those (and open
`flaws/`) into the package for an upstream fix. Unmarked entries are
never harvested.

Append-only, but prunable to cold storage: once an entry is explicitly
marked `RESOLVED` / `superseded` / fixed, move it **verbatim** into
`archive.md` in this directory so startup reads only the live entries.
`ledger-mem prune` reports which entries are archive-eligible; age alone
never makes an entry eligible.

<!-- TEMPLATE — copy below the last entry:
---
## YYYY-MM-DD — <agent> / <model>
- **Problem:** <what went wrong or was slower than it should be>
- **Cost:** <rough time/effort wasted>
- **Cause:** <root cause if known>
- **Workaround / fix:** <what worked, or "unresolved">
- **Prevent next time:** <protocol/context change that would have avoided it>
- **Upstream:** candidate  ← add this line ONLY for protocol-level friction
  worth a core fix; omit entirely for project-local friction.
-->

## 2026-09-11 — Noor / glm-5.3-flash
- **Problem:** shipping two independent `core/` fixes in one release against the "manifest regen in the same commit" rule — the manifest hashes the whole tree, so regenerating it for commit 1 would have hashed commit 2's still-uncommitted files, and a checkout of commit 1 would have failed verify. Plus a test-harness slip: assigning a multi-word command with `VAR="x" cmd` prefix syntax runs only the assignment, not the command.
- **Cost:** one juggling cycle per problem (~10 minutes total): copy the sibling edit aside, restore to HEAD, regen, commit, copy back, regen; one failed test-suite run.
- **Cause:** whole-tree manifest + sequential dependent commits; sh test driver built a command as an assignment prefix instead of a wrapper function.
- **Workaround / fix:** copy not-yet-committed core files to /tmp, `git checkout --` them, regen + commit fix 1, copy back, regen + commit fix 2 (no stash — a peer's uncommitted files were in the tree). Test drivers use wrapper functions.
- **Prevent next time:** keep one core change in flight at a time (edit → verify → regen → commit → next); the cp-aside dance is the documented fallback when two fixes must ship in one release.
