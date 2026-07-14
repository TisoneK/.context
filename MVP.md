# MVP — Public Release Plan & Feature Roadmap

The plan for taking the `.context/` workflow public: what ships in the
MVP, what comes after, and which logged flaws each feature retires.
This file is the **single home for advanced/future feature ideas** — when
a session or a flaw entry suggests a feature that's out of scope for a
doc fix, it gets captured here, not lost in chat history.

**Status legend:** `mvp` (ships in the first public release) ·
`future` (after MVP) · `exploring` (direction agreed, design open)

---

## The distribution model (the MVP's spine)

**Today** the package is a private git repo (`TisoneK/.context`) that
every session must clone — which created a whole flaw class: visibility
claims going stale, PAT confusion, cloud sessions that couldn't reach
the protocol at all (see `flaws/log.md`, task2sms Sessions 1–2).

**The MVP replaces the clone with a versioned archive:**

```text
context-0.1.0.zip  →  unpacks to  ../.context/
```

- **Semver-tracked releases** — `context-<MAJOR.MINOR.PATCH>.zip`.
  Breaking changes to the `.context/` spec or skeleton bump MAJOR;
  new features (roles, pitfalls, skeleton files) bump MINOR; wording
  and fixes bump PATCH.
- **The archive is the offline source of truth.** No GitHub account, no
  PAT, no clone, no network needed to run a session — the user hands
  the agent (or drops beside the project) one file. The git repo remains
  the *development* home of the package; the zip is its *distribution*.
- **`VERSION` file inside the package root** — agents and kickoffs read
  `../.context/VERSION` and record it in `workflows/active.md` and their
  session entries, so every project's memory says which protocol version
  produced it.
- **`CHANGELOG.md` inside the package** — one entry per release, so an
  agent syncing a project bootstrapped on 0.1.0 against a 0.3.0 package
  can see exactly what changed in between.

**Flaws this retires by design:** the package-visibility claim going
stale (nothing to clone), PAT-for-the-package entirely, the "protocol
unreachable mid-session" failure, and the `.context` vs `.context-package`
clone-name confusion (an unzip has exactly one destination).

---

## MVP features

### 1. Versioned archive distribution — `mvp`
As above. Build step: a release script that zips the package (excluding
`.git/`, dev-only files), stamps `VERSION`, appends `CHANGELOG.md`, and
names the artifact. Open question: distribution channel (GitHub Releases
on a public repo vs. direct share) — decoupled from the repo's own
visibility either way.

### 2. `check` — the mechanical verifier — `mvp`
The protocol's rules are prose; a weak model needs a command. One script
shipped in the package (`bin/check` or `check.sh`) that an agent runs
before every commit, mechanically enforcing what Pitfalls #38–41 and the
bootstrap guards state in words:

- staged diff contains no credential markers (`x-access-token`,
  `github_pat_`, `ghp_`, `gho_`, key-looking strings)
- append-only files (`sessions.md`, `backlog.md`, `decisions.md`, both
  logs) show additions only
- no unfilled `<PLACEHOLDER>`s outside HTML template comments
- no mixed-surface staging (project paths and `.context/` paths staged
  together)
- bootstrap sanity: `.context/.git` and protocol editions absent from
  the project's memory dir
- exit-readiness mode (`check --exit`): clean tree, `tasks/current.md`
  cleared, session entry present for today

Open question: portability — POSIX shell + a Python fallback, since
sandboxes vary. The protocol gains one line: "run `../.context/bin/check`
before each commit; a failing check blocks the commit."

### 3. Single-source editions — `mvp`
The two editions duplicate ~90% of their text (all 42 pitfalls, the Ten
Binding Rules, the `.context/` spec); every dual edit risks drift. MVP
restructures to **one core protocol + thin platform deltas** (local /
cloud), with the editions either generated at release-build time (the
zip ships the familiar two files, built from core + delta) or replaced
by explicit "read core, then your platform file" instructions. Build-time
generation preferred — zero change to what agents consume.

### 4. Baked protocol — offline entry per project — `mvp`
With the archive model, `../.context/` is already the offline source, so
the earlier "commit PROTOCOL.md into every project" idea shrinks to:
record in `workflows/active.md` **both** the package version the project
last synced against and the archive filename, so a session that finds no
`../.context/` on disk can say precisely which file to ask the user for
— instead of improvising from memory (task2sms Session 2's failure).

### 5. Session concurrency convention — `mvp` (convention), `future` (tooling)
The protocol implicitly assumes serialized sessions; two concurrent
agents interleave session numbers and race pushes. MVP states the rule:
**one agent per project repo at a time**; `tasks/current.md` doubles as
the lock (an in-progress task from another live session = do not start;
a stale one = takeover per the existing dead-session rule, noted in the
session entry). Tooling (lock timestamps, takeover detection in `check`)
is `future`.

---

## Future / advanced (post-MVP)

- **Upgrade flow between package versions** — `future` — when a project
  bootstrapped on 0.1.0 meets a 0.4.0 package, structural sync (SYNC.md)
  covers READMEs, but skeleton *shape* changes (new files, renamed dirs)
  need migration notes per release in `CHANGELOG.md` ("0.3.0: add
  `kickoff.md` via the Path B backfill").
- **Flaw feedback loop for external users** — `exploring` — today flaws
  flow back because the maintainer runs the projects. Public users need
  a path: a `FLAWS-UPSTREAM.md` template they can share, or a public
  issues channel. Constraint: flaw entries can contain project details —
  the template must say what to redact.
- **Community roles** — `future` — `roles/` accepts contributed
  overlays (migration-engineer, perf-engineer, incident-responder…)
  once the overlay contract in `roles/README.md` is versioned.
- **Kickoff generator** — `exploring` — a tiny script or form that
  emits a pre-filled external kickoff (today's manual Pre-Flight), for
  first sessions only; inbound kickoffs already cover the rest.
- **Model-capability profiles** — `exploring` — the Ten Binding Rules
  card is the floor for weak models; a profile system ("strict mode":
  check runs mandatory, smaller step budget, no improvisation clauses)
  could adapt the protocol's freedom to the model driving it.
- **Windows-native paths** — `future` — the docs are POSIX-flavored;
  `check` and the kickoff commands need PowerShell equivalents before a
  general public release.

---

## Non-goals (decided, not drifting back in)

- **System-specific flows in the universal protocol** — sandbox venv
  paths, scaffold `.env` quirks, platform pip aliases. These live in each
  project's `system/environments.md` / `inefficiencies/log.md`; agents
  identify and learn them per environment (maintainer ruling, 2026-07-13,
  `flaws/log.md`).
- **The package as a submodule** — the sibling/archive model stands;
  submodules re-couple every project clone to package availability.
