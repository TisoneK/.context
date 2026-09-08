# Design: Collaboration that feels like coworkers (core 0.9.0)

**Status:** implementing
**Proposed:** 2026-09-04 (maintainer; seeded by empirical evidence in the
LocalMind fleet)
**Target:** core 0.9.0 (MINOR — additive `note` event type, reframed
collaboration prose, tool bug-fixes, Windows/CRLF root fix. No breaking
change to the existing event contract: the seven legal event types keep
their exact meaning; `note` is new and non-gating.)

---

## Problem

Peer collaboration shipped in 0.6.0–0.8.0. It works, but downstream
evidence shows it is **less effective than the single-agent protocol** it
was meant to extend. Three failure modes, all evidenced in the fleet:

### 1. The protocol models coordination as a courtroom, not an office

The event vocabulary is seven heavyweight legal instruments —
`claim → proposal → assessment → agreement → correction → handoff →
release` — every one requiring a separate `chore(ledger):` commit and a
coordination-branch push; `agreement` additionally requires ≥2
participants, cross-referenced proposals AND assessments, a selected
option, and a named owner.

Empirically, in `TisoneK/LocalMind` the trail is **42 events across 4
agents** (claude-opus-4.8, zcode, opencode, buffy). Of those:

- The overwhelming majority are **solo `claim → release` pairs by one
  agent** — the ceremony is being paid as pure overhead over single-agent
  mode, for zero coordination benefit.
- **Not one `agreement` event exists** in the entire trail. The consensus
  mechanism the whole design is built around never once converged.
- The genuine multi-agent moments (`issue=agent-followthrough-persistence`,
  `B-2026-08-30-7`) show **parallel claims on identical paths**
  (`loop.py,prompts.py,turn_outcome.py`) by claude, then opencode, while
  zcode reviews — and **no assessment/agreement ever resolves the
  overlap**. They talked past each other.

### 2. The framing primes rivalry, and there is no room to just talk

The README says outright: *"Competing proposals are expected."* An agent
doing a friendly peer code-review has no event type for it — the only
containers are legal instruments — so it overloads `proposal` and then has
to **defensively disclaim** its own event:

> *"These are notes/suggestions — no competing proposal, no ownership
> change. The follow-through claim stays opencode's."*
> — zcode, `20260831T211913Z-zcode-d794d27d.md`

That disclaimer is the tell: the protocol has no _office chat_. Agents
that want to say "hey, I'm on the web side, you take the loop" or "nice
catch" or "FYI that test is flaky, re-run it" must either misuse a formal
type or drop the note into a shared durable file — which is the logged
anti-pattern **B-2026-08-18-1**: a peer appended coordination into a
review report; without a manual fold-in it would have been lost.

### 3. The tooling lies and hangs (and dies on Windows)

Logged, reproduced, in-fleet:

- **`status`/`check` report closed claims as "Active" forever**
  (B-2026-09-01, Session 406). `released()` / `claim_closed()` only link a
  release to its claim by the claim's **event ID**, but every real release
  in the trail cited a **commit SHA** (the more useful pointer, and
  explicitly allowed by the contract). SHA-only releases never close their
  claim → peers believe finished work is still open.
- **`check` hangs > 3.5 min on ~23 events** (killed). It is O(n²)–O(n³) in
  files, and every field read forks `sed`+`head`; thousands of subprocess
  spawns, murderous under Git Bash on Windows.
- **Windows CRLF corrupts the integrity system at the root**
  (B-2026-08-30-17, Session 407): with `core.autocrlf=true`, `MANIFEST.sha256`
  is checked out CRLF, so the `sh` port dies parsing it
  (`sha256sum: 'bin/…ps1'$'\r': No such file`) and the `.ps1` port hashes
  CRLF bytes against an LF-computed manifest → **every core file reported
  FAILED** on a git-clean tree. There is **no `.gitattributes`** anywhere
  in the package or in bootstrapped projects to prevent it.

---

## Fix — four parts, one release

### Part A — `note`: the office channel (the heart of the fix)

Add an eighth event type, `note`, that is the deliberate opposite of the
legal instruments: **no required refs, no participants, no owner, no gate
consequence.** It is how coworkers talk.

- `emit note --session S --agent A --issue I --body "…"` — the only
  required fields are the universal ones. Optional `--to <agent>` and
  `--re <event-id|path|commit>` give a note a target without ceremony.
- `check` **never fails on a note** and never requires one to be
  "resolved." Notes are chatter, not obligations.
- `status` grows a **"Recent chatter"** feed so a joining agent reads the
  human back-and-forth first, the way you'd catch up in a team channel.

This gives agents the natural, low-stakes back-and-forth they lack, and
removes every incentive to overload `proposal`/`assessment` or to drop
notes into shared durable files (kills B-2026-08-18-1's root cause).

### Part B — De-escalate: coworkers, not rival bidders

- Rewrite the collaboration README and both protocol editions so peers are
  framed as **one team with a shared goal**. Replace *"Competing proposals
  are expected"* with the cooperative framing: when two agents see it
  differently they **compare notes and pick the stronger option
  together — same side of the table.**
- Make the heavy `proposal → assessment → agreement` ceremony **explicitly
  the exception, reserved for a genuine conflict** (same paths,
  incompatible changes). The default path for the common case
  (non-overlapping work, or reviewing a peer's diff) is **`note` +
  `claim`/`release`.** The light path is the documented norm; the courtroom
  is the escalation.
- A peer review is a `note --re <claim>`, not a `proposal`. No more
  defensive disclaimers.

### Part C — Make the tooling truthful, fast, and CR-tolerant

- **Truthful closure:** `released()` (in `ledger-collab`) and
  `claim_closed()` (in `ledger-collab-check`) recognize a claim as closed
  when a later `release`/`handoff` either (a) references the claim event ID
  **or** (b) matches the claim's `session`+`issue` and overlaps its
  `paths` (the SHA-only case). Weak agents don't reliably copy event IDs;
  closure must infer from what they actually do.
- **No more hang:** rewrite `ledger-collab-check` to parse every event
  **once** into an in-memory index (single `awk` pass), then run all checks
  over the index — no re-globbing, no per-field `sed` forks. Add progress
  output so it can never look hung.
- **Notes non-gating** in `check`; **chatter feed** in `status`.
- **CR-tolerance:** `field()` and manifest/line parsing in the `sh` ports
  strip a trailing `\r`, so an already-CRLF checkout degrades gracefully
  instead of dying.
- Mirror every behavior change in the `.ps1` ports.

### Part D — Windows/CRLF root fix

- Add a package-root **`.gitattributes`** forcing `eol=lf` on `core/**`,
  `bin/*`, `*.ps1`, `*.sh`, `*.md`, and `MANIFEST.sha256` — so a Windows
  clone can never get CRLF into the manifest-hashed tree. (Root file lives
  outside `core/`, so it is never itself hashed.)
- Ship **`templates/.gitattributes`** and have `ledger-sync bootstrap`
  install it as `.context_ledger/.gitattributes`, giving every future
  bootstrapped project LF enforcement on `.context_ledger/core/**` and
  `.context_ledger/memory/**` (fixes B-2026-08-30-17 and the Session-407 sh
  manifest-parse death at the root).
- CHANGELOG migration note documents the one-time remediation for
  repos already checked out CRLF: `git add --renormalize .` (or
  `core.autocrlf=false` + `git checkout -- .context_ledger`).

---

## Release mechanics (invariants — do not skip)

- Bump `core/VERSION` → `0.9.0`; add a `core/CHANGELOG.md` entry (newest
  first) with the migration note above.
- Update `core/schemas/ledger-schema.md` + `ledger.schema.json` for the
  `note` type (additive; `note` requires only the universal fields).
- Update the `core/templates/AGENTS.md` digest — the **weak-agent floor**:
  the collaboration summary a small local model actually reads must teach
  the light path (`note` + `claim`/`release`) first.
- **Regenerate `core/MANIFEST.sha256`** (`sh core/bin/ledger-sync manifest`)
  in the **same commit** as the `core/` changes.
- The maintainer's Mac has no `pwsh`; `.ps1` changes are validated
  statically and manifest-format cross-checked, per the standing note in
  the vendored-core design.

## Update — fleet-wide harvest (2026-09-04)

A read-only sweep of the other bootstrapped repos (proxigrid, glyph,
scrapamoja, vert, InjectX, PortalLens) sharpened the picture:

- **The collab lifecycle was never dogfooded fleet-wide.** LocalMind is the
  *only* repo that ever emitted a collab event. No `agreement`/`release`
  lifecycle ran anywhere else; glyph and vert record it as
  "available but not opted in." Lightening the ceremony is clearly right —
  nobody could afford the heavy path.
- **PortalLens is the real concurrency evidence** (it predates the tooling,
  so it coordinated by hand). It shows exactly the friction `note` targets:
  two agents editing the same file coordinating via a message *buried in an
  inefficiency log*; redundant re-work when concurrent branches touched the
  same renderer; and **peer messages smuggled into durable logs because
  there was no informal channel** ("the next Windows session should run it
  and log the result"). The `note` gap is not hypothetical — agents already
  improvised it in the wrong place.
- **Session-number collisions are real** (PortalLens: two agents both logged
  "Session 8" the same day; "nothing in `.context_ledger/` prevented it"). Folded
  in as a lightweight guidance rule, not a new mechanism.
- **CRLF is the dominant, still-open, cross-repo failure** (proxigrid,
  glyph, PortalLens, scrapamoja). glyph patched `.gitattributes` locally but
  scoped it to `core/` only and was then bitten by CRLF corrupting the
  append-only `memory/` logs (a 229-line phantom diff). Part D's template
  covers `memory/**` too, closing that second hole.
- **Two concrete new bugs folded into Part C/D:**
  - `ledger-gates.ps1` crashes on Windows — `Cannot bind parameter because
    parameter 'PathType' is specified more than once` — two `Test-Path`
    calls chained with `-or` without parenthesizing each. **No gate runs.**
  - `ledger-sync` on Windows Git Bash dead-ends with `need sha256sum or
    shasum on PATH`; the error should point at the `.ps1` port instead of
    being a dead end.

## Non-goals

- No change to the immutable-event / one-file-per-event model — it is
  correct and is what lets concurrent agents publish without merge
  conflicts.
- No coordinator/leader election — peer model stays.
- No change to product-branch isolation topology.
