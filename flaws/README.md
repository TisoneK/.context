# Consolidated Flaws (package-level — flows in from projects)

This directory is where workflow-level flaws observed across **all
projects** using this protocol are consolidated. Each project's
`.context/flaws/log.md` is the source of truth for that project; this
directory is where patterns are back-ported so the protocol package
itself can be improved.

## The flow

```
Project session hits a workflow flaw
  → logged in the project's .context/flaws/log.md
  → when a pattern repeats (or periodically), summarized here
  → protocol/skeleton/roles updated in this package to fix it
  → the project's flaw entry gets a "Fixed in package" line
  → new projects bootstrap from the fixed skeleton
```

## How to use this directory

- **Reading:** Before improving the protocol, scan this log for patterns.
  If the same flaw appears across multiple projects, it's a high-priority
  fix.
- **Writing:** When back-porting a project flaw, copy the entry here with
  a `Source:` line pointing to the project + session. Don't copy
  one-off flaws that are unlikely to recur — those stay in the project.
- **Fixing:** When you fix a flaw in the protocol (a new pitfall, a
  reworded step, a new template field), note the fix in the entry's
  `Status:` line with the commit SHA. Then the project that reported it
  can update its own entry to "Fixed in package <sha>".

## Format

```
---
## YYYY-MM-DD — <agent> / <model> (consolidated from <project>, Session N)

- **Flaw:** <what in the protocol or .context/ system didn't work>
- **Symptom:** <what happened to the agent — the observable friction>
- **Root cause:** <why the protocol/.context/ let this happen>
- **Suggested fix:** <concrete change to the package>
- **Source:** <project repo> — .context/flaws/log.md, Session N
- **Status:** open | fixed in <commit-sha> on <date>
```

## Current open flaws (consolidated from LocalMind)

The 4 flaws below were observed by GitHub Copilot / DeepSeek V4 Flash
Free during LocalMind Session 3 (2026-07-11). They are all about the
protocol not guiding the agent well enough during `.context/`-only
tasks. All 4 are open — none have been fixed in the protocol yet.
