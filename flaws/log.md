# Consolidated Flaws Log (package-level)

Workflow-level flaws consolidated from all projects using this protocol.
See `README.md` in this directory for the flow and format.

---
## 2026-07-11 — GitHub Copilot / DeepSeek V4 Flash Free (consolidated from LocalMind, Session 3)

- **Flaw:** The protocol's Step 3 ("Read `.context/`") doesn't emphasize hard enough that reading `workflows/active.md` is a **binding instruction** to load and execute the referenced protocol — not passive documentation.
- **Symptom:** Agent read `workflows/active.md` in its first tool calls, saw that the protocol lives in `TisoneK/.context`, but then jumped straight to editing `.context/` files without fetching or following the protocol. User had to redirect: "Don't you have the workflow?"
- **Root cause:** The protocol describes the workflow file as something to read, not as an instruction to act on. There's no explicit "after reading the workflow, immediately load the protocol it references before any other tool use" rule. An agent can read the workflow passively (as context) rather than actively (as a command).
- **Suggested fix:** Add to Step 3 (or a new pitfall): "Reading `workflows/active.md` is a binding instruction. After reading it, immediately fetch and load the protocol it references before any other tool use. Don't treat it as documentation — it's the instruction set for this session." Consider adding a dedicated "Load the protocol" sub-step between Step 3 (read `.context/`) and Step 4 (install deps).
- **Source:** TisoneK/LocalMind — `.context/flaws/log.md`, Session 3
- **Status:** open

---
## 2026-07-11 — GitHub Copilot / DeepSeek V4 Flash Free (consolidated from LocalMind, Session 3)

- **Flaw:** The protocol doesn't tell the agent **where the protocol itself lives** when the agent is working on a project (not on the package repo). An agent on a fresh project clone has the project's `.context/` but not the protocol file — it has to fetch it from `TisoneK/.context` on GitHub, and the workflow file says "from the `TisoneK/.context` package" but doesn't say "fetch it from GitHub using these coordinates."
- **Symptom:** Agent tried multiple wrong local paths to find the protocol: VS Code prompts folder, workspace globs (`**/*protocol*`, `**/*.instructions.md`, `**/*.prompt.md`). All returned nothing. 4 failed search tool calls before using `github_repo` to fetch the protocol from `TisoneK/.context`.
- **Root cause:** The workflow file references the package by name ("from the `TisoneK/.context` package") but doesn't give explicit fetch instructions. The protocol's Step 1–3 don't say "if you don't have the protocol file locally, fetch it from the URL in `workflows/active.md`." An agent that hasn't internalized the two-repo model (package vs project) will search locally first.
- **Suggested fix:** Add to `workflows/active.md` template an explicit "Protocol source" field: `github.com/TisoneK/.context/blob/main/ai-engineering-protocol.md` (or the local edition). Add to Step 3: "If the protocol file is not present in the working directory, fetch it from the URL in `workflows/active.md`'s Protocol source field."
- **Source:** TisoneK/LocalMind — `.context/flaws/log.md`, Session 3
- **Status:** open

---
## 2026-07-11 — GitHub Copilot / DeepSeek V4 Flash Free (consolidated from LocalMind, Session 3)

- **Flaw:** The protocol's execution order (Phase 1 before any editing) is stated as a sequence but not enforced as a **rule**. An agent can treat a small task ("initialize `.context/`") as "too small for the protocol" and skip Phase 1 entirely.
- **Symptom:** Agent registered itself in `ai-models.md`, added its environment to `environments.md`, logged its session in `sessions.md`, updated `workflows/active.md`, and set `tasks/current.md` — all before completing Phase 1 (pull, read docs, discovery). The edits were correct but the sequence violated Steps 2–6. Required a backtrack to re-do discovery properly.
- **Root cause:** The protocol says "execute these steps sequentially" but doesn't explicitly say "regardless of task size" or "even for `.context/`-only tasks." An agent reasoning about efficiency might conclude that a trivial task doesn't need the full Phase 1 setup.
- **Suggested fix:** Add to the protocol's Autonomous Execution Steps preamble: "These steps run in order for every session, regardless of task size. A one-line `.context/` edit still requires Phase 1 (pull, read `.context/`, read docs, discovery, baseline) before any file is modified. Skipping Phase 1 because the task seems small is the most common protocol violation." Add as a Common Pitfall.
- **Source:** TisoneK/LocalMind — `.context/flaws/log.md`, Session 3
- **Status:** open

---
## 2026-07-11 — GitHub Copilot / DeepSeek V4 Flash Free (consolidated from LocalMind, Session 3)

- **Flaw:** The protocol doesn't explicitly distinguish **two surfaces** (the project vs `.context/`) in a way that forces the agent to declare which one it's working on.
- **Symptom:** Agent mixed `.context/` edits (registering itself, logging its session) with what should have been protocol-governed project work, without distinguishing the two. The `chore(context):` commit prefix exists but wasn't enough to enforce the mental separation.
- **Root cause:** The protocol has one execution flow that covers both surfaces. There's no explicit "I am now working on `.context/`" or "I am now working on the project" declaration step.
- **Suggested fix:** Add a "Two Surfaces" section to the protocol (early, before Phase 1) that defines: (1) The project — product code, normal commit prefixes, friction → `inefficiencies/`. (2) `.context/` — agent memory, `chore(context):` prefix, friction with the system → `flaws/`. State: "Know which surface you're on at all times."
- **Source:** TisoneK/LocalMind — `.context/flaws/log.md`, Session 3
- **Status:** open

---
## 2026-07-11 — Super Z / GLM-4.5 (consolidated from package review, Session 4)

- **Flaw:** `roles/README.md` referenced "Phase 5 (Steps 15–17)" but the base editions have only 4 phases. Steps 15–17 are in Phase 4 (Report & Context), not a separate Phase 5.
- **Symptom:** An agent trying to map role instructions to edition steps would look for a Phase 5 that doesn't exist, causing confusion about which phase the memory-update steps belong to.
- **Root cause:** The roles/README.md was written with a 5-phase mental model, but the editions were structured into 4 phases. The phase label was added for clarity but introduced a mismatch.
- **Suggested fix:** Change "Phase 5 (Steps 15–17)" → "Phase 4, Steps 15–17" (or drop the phase label entirely and reference steps by number only).
- **Source:** Package review by Super Z / GLM-4.5, Session 4
- **Status:** fixed in this commit — `roles/README.md` now says "Phase 4, Steps 15–17"

---
## 2026-07-11 — Super Z / GLM-4.5 (consolidated from package review, Session 4)

- **Flaw:** `localmind-review.md` sat at the package root, making it look like a review of the `.context` package itself rather than an example deliverable from a project session.
- **Symptom:** A new visitor to the repo (human or agent) might confuse the example review with a review of the protocol package, misreading LocalMind-specific findings as protocol findings.
- **Root cause:** No `examples/` directory existed; the example file was placed at the root for convenience. The README explained it was an example, but the file's location didn't reinforce that.
- **Suggested fix:** Move to `examples/localmind-review.md`. Create the `examples/` directory as the home for sample deliverables.
- **Source:** Package review by Super Z / GLM-4.5, Session 4
- **Status:** fixed in this commit — moved to `examples/localmind-review.md`, README link updated

---
## 2026-07-11 — Super Z / GLM-4.5 (consolidated from package review, Session 4)

- **Flaw:** The quickstart doc (`context-workflow-quickstart.md`) existed in the user's local uploads but was never committed to the package repo. New users/agents had no entry point explaining the two-repo mental model and bootstrap steps.
- **Symptom:** A new user cloning `TisoneK/.context` for the first time sees protocol files, a skeleton, roles, and an example review — but no "how do I actually use this?" guide. They have to read the README and infer the workflow.
- **Root cause:** The quickstart was written as a separate doc but never added to the repo. The README covers usage briefly but doesn't walk through the full two-repo model.
- **Suggested fix:** Commit as `QUICKSTART.md` at the package root. Add to the README contents table.
- **Source:** Package review by Super Z / GLM-4.5, Session 4
- **Status:** fixed in this commit — added as `QUICKSTART.md`, linked from README

---
## 2026-07-11 — Super Z / GLM-4.5 (consolidated from package review, Session 4)

- **Flaw:** The cloud edition's `secrets/github-pat` guidance didn't distinguish cloud-sandbox persistence (session-only) from local-agent persistence (survives across sessions). The text said the file "dies with the sandbox" — correct for cloud, misleading for local agents who might read the cloud edition for reference.
- **Symptom:** A local agent reading the cloud edition might wrongly conclude that `.context/secrets/` is always ephemeral, missing that on a local machine the file persists and can be reused across sessions.
- **Root cause:** The guidance was written from the cloud-sandbox perspective only. The two persistence models (cloud ephemeral vs local persistent) weren't called out as a distinction.
- **Suggested fix:** Add explicit cloud-vs-local sub-bullets under the `secrets/github-pat` guidance: cloud = session-only convenience, local = persists across sessions.
- **Source:** Package review by Super Z / GLM-4.5, Session 4
- **Status:** fixed in this commit — `ai-engineering-protocol.md` Step 1 now has cloud/local sub-bullets

---
## 2026-07-11 — Super Z / GLM-5.2 (Session 5) — UPDATE: flaws 1–4 fixed

Flaws 1–4 (consolidated from LocalMind Session 3, GitHub Copilot) are
now **fixed in this commit**. All four suggested fixes applied to both
protocol editions:

- **Flaw 1 (binding instruction):** Fixed. Step 3 now says "Reading
  `workflows/active.md` is a binding instruction, not passive
  documentation." Added as Pitfall #27 in both editions.
- **Flaw 2 (protocol source):** Fixed. `workflows/active.md` template
  now has a `Protocol source` field with the GitHub URL.
- **Flaw 3 (no-task-too-small):** Fixed. Protocol preamble now says
  "No task is too small for Phase 1." Added as Pitfall #28.
- **Flaw 4 (two surfaces):** Fixed. Both editions now have a "Two
  Surfaces — Know Which One You're On" section before Phase 1.

---
## 2026-07-11 — Super Z / GLM-5.2 (consolidated from LocalMind, Session 5)

- **Flaw:** Agents are asked to record their model identity in `.context/system/ai-models.md` and `agents/sessions.md`, but the protocol gave them no reliable way to determine it. The system prompt doesn't state the model version, and the protocol's Pre-Flight said "agent fills in — records best self-description." This led the agent to guess "GLM-4.5" in Session 1, which propagated verbatim through Sessions 2–4. The actual model was GLM-5.2.
- **Symptom:** All `.context/` entries from Sessions 1–4 recorded the wrong model (GLM-4.5 instead of GLM-5.2). The user caught it in Session 5 by asking "why did you say 4.5?"
- **Root cause:** The protocol treated model identity as something the agent could self-determine. It can't — system prompts don't reliably state the model version. The user knows (they selected it in the UI); the agent doesn't.
- **Suggested fix:** Move Agent Identity from "agent fills in" to "user fills in — agent copies, never guesses." Add a pitfall: "Never guess your own model version. If it's not in Pre-Flight, ask once. If the user doesn't know, record 'unknown'."
- **Source:** TisoneK/LocalMind — `.context/flaws/log.md`, Session 5
- **Status:** fixed in this commit — Agent Identity section rewritten in both editions; Pitfall #25 added.

---
## 2026-07-11 — Super Z / GLM-5.2 (consolidated from LocalMind, Session 5)

- **Flaw:** The protocol didn't clearly mark session entry, phase transitions, or exit. Agents didn't know where to start (Copilot jumped to editing before reading the workflow), didn't know how to transition between phases, and didn't know how to end (Copilot had to be reminded to commit and push). This is the root cause behind flaws 1–4 — they're all symptoms of missing lifecycle markers. The user explicitly flagged this as "the biggest flaw."
- **Symptom:** Copilot (Session 3) didn't know where to start (skipped Phase 1), didn't know how to end (user had to remind it to commit/push). The protocol had 19 steps but no explicit "you are done when..." checklist.
- **Root cause:** The protocol had 19 steps in 4 phases but no explicit ENTRY marker (what to do first), no TRANSITION markers (when to move between phases), and no EXIT checklist (what must be true before the session is done). An agent could finish the work but not realize it hadn't pushed, because there was no checklist saying "push is part of done."
- **Suggested fix:** Add a "Session Lifecycle — Entry, Transitions, Exit" section to both editions, before Phase 1. ENTRY: read Two Surfaces + Pre-Flight first, don't edit until Phase 1 is done. TRANSITIONS: phase-boundary conditions. EXIT: mandatory checklist (all fixes committed AND pushed, report committed AND pushed, .context/ updated committed AND pushed, PAT unset, chat summary delivered). Add: "If the user has to remind you to commit or push, the protocol failed — log it as a flaw."
- **Source:** TisoneK/LocalMind — `.context/flaws/log.md`, Session 5
- **Status:** fixed in this commit — both editions now have the Session Lifecycle section with ENTRY/TRANSITIONS/EXIT. Pitfall #26 added.

---
## 2026-07-11 — DeepSeek V4 Flash Free (cold start, 2nd instance — consolidated from LocalMind)

- **Flaw:** No discovery mechanism. The protocol assumes the agent opens `.context/` first, but nothing at the repo root signals that `.context/` exists or that a protocol should be followed. A fresh agent with no prior session context treats the repo as a product to run, not a project to work on under protocol.
- **Symptom:** In a cold-start session (no uploaded protocol file, no prior chat context), the agent received "Start context workflow" and interpreted it as "start LocalMind's Context Builder feature" (the app's runtime context system). It explored the codebase, started the backend server, checked the health endpoint, and reported "The context workflow is now running" — referring to LocalMind's engine, not the agent-memory protocol. At no point did it read `.context/`, open `workflows/active.md`, fetch the protocol, set `tasks/current.md`, or log a session entry.
- **Root cause:** Every prior flaw fix (binding-workflow rule, protocol source field, session lifecycle, no-task-too-small) assumes the agent has already opened `.context/` and is reading `workflows/active.md`. But there's nothing at the repo root that tells a fresh agent "read `.context/` first." The `.context/` directory doesn't appear in the code — it's metadata, not code — so code exploration never surfaces it. A naming collision made it worse: "context" is overloaded in LocalMind (the app has a "Context Builder" feature; the agent memory is `.context/`), so grepping for "context" surfaces the product feature, not the protocol.
- **Suggested fix:** Add a discovery file at the repo root that agents auto-load. The emerging industry convention is `AGENTS.md` (tool-agnostic) plus a `CLAUDE.md` symlink/copy (Claude-specific discovery). Content: "This repo uses the `.context/` agent-memory protocol. Before doing any work: 1. Read `.context/workflows/active.md` — it names the protocol edition to follow. 2. Fetch that protocol from the URL in its 'Protocol source' field. 3. Follow the protocol's Phase 1 before editing any file." Add `AGENTS.md` to `context-skeleton/` so new projects get it automatically. Note: this is not a silver bullet — agents must still choose to read it — but it's strictly better than the current state (zero discovery mechanism). Layered defense: (1) `AGENTS.md` at root, (2) `CLAUDE.md` at root, (3) user explicitly saying "follow the protocol" at session start.
- **Source:** TisoneK/LocalMind — cold-start session, 2nd instance of DeepSeek V4 Flash Free missing the protocol (1st instance was Session 3, which found `.context/` but didn't follow it). This 2nd instance is the cleaner data point — no prior context to bias it.
- **Status:** open — fix deferred until after a cold-start test of GLM-5.2 to confirm the pattern across models (if GLM-5.2 also misses it, it's a protocol gap; if GLM-5.2 finds it, it's a model-specific observation).

---
## 2026-07-11 — Super Z / GLM-5.2 (consolidated from LocalMind, Session 7) — PAT leak in chat summary

- **Flaw:** The protocol says "never write the PAT to any file" and "never echo secret values from `secrets/`," but it never explicitly says "don't include the PAT value in chat output or rotation reminders." An agent following the Exit checklist's "remind the user to rotate the PAT" step can reasonably include the full token value — defeating the secret-handling rules. The PAT lives as an env var, not a `secrets/` file, so the `secrets/README.md` "never echo a value" rule doesn't feel applicable.
- **Symptom:** Session 7's final chat summary included the full PAT in plaintext: "⚠️ Rotate the PAT — `github_pat_11ASCEY4Q0n1QCPOjmffJy_...` was used this session and is now unset." The agent's intent was good (reminding the user to rotate), but including the actual value leaked it into the chat transcript, which may be logged, shared, or screenshotted.
- **Root cause:** The protocol's secret-handling rules are scoped to files and `secrets/` values, not to the PAT env var in chat output. The Exit checklist says "remind the user to rotate the PAT" but doesn't say "reference the token by last 4 characters, never the full value." The agent reasoned: "the user pasted it, so they know it; including it makes the reminder more useful." That reasoning is understandable but wrong — the chat transcript is not a secure channel.
- **Suggested fix:** Add to both protocol editions, in the PAT section: "Never echo the PAT value in chat output. This includes rotation reminders, error messages, and 'for your reference' notes. The user pasted it; they know it. Your reminder should say 'Rotate the PAT' — not 'Rotate the PAT: `github_pat_...`'. If you need to reference which token, use the last 4 characters: 'Rotate the PAT ending in `5KV`.' The full value must never appear in your output, in any form." Add as a pitfall in both editions.
- **Source:** TisoneK/LocalMind — `.context/flaws/log.md`, Session 7
- **Status:** fixed in this commit — both editions now have the rule + pitfall

---
## 2026-07-11 — Super Z / GLM-5.2 (Session 8) — UPDATE: Session 7 flaws fixed

Flaws consolidated from LocalMind Session 7 are now **fixed in this commit**:

- **blob/ vs raw/ URL:** Fixed. `context-skeleton/workflows/active.md`
  template now has separate "Protocol source (raw)" and "Protocol
  source (blob)" fields, plus a fallback note. LocalMind's
  `workflows/active.md` updated too.
- **Append-only dedupe exception:** Fixed. `context-skeleton/README.md`
  Rule 2 now has an exception for byte-identical duplicates. LocalMind's
  `.context/README.md` updated too. Applied to the duplicate Session 6
  entry in LocalMind's `agents/sessions.md`.
- **PAT leak in chat:** Fixed. Both protocol editions now have the
  "Never echo the PAT value in chat output" rule (in the PAT section
  for cloud; in the secrets rule for local) and Pitfall #29.

---
## 2026-07-11 — Super Z / GLM-5.2 (consolidated from LocalMind, Session 8) — pull-before-inspect gap

- **Flaw:** The protocol says "pull before starting work" (Step 2), but when a user tells an agent mid-session to "check what another session did" or "pull changes," the agent doesn't have an explicit rule to pull first. The agent may inspect stale local state and report wrong information.
- **Symptom:** When told "maybe check what the session did first," the agent jumped straight to `git show` on the latest local commit, assuming local was current. Remote was ahead. The inspection was performed on stale state.
- **Root cause:** The protocol's pull rule is scoped to session start (Step 2), not to any point where remote may have moved ahead. There's no rule for mid-session sync.
- **Suggested fix:** Add: "Before inspecting another agent's work, or whenever the user references work you haven't seen — fetch first. If remote is ahead, pull before inspecting." Add as a pitfall.
- **Source:** TisoneK/LocalMind — `.context/flaws/log.md`, Session 8
- **Status:** fixed in this commit — both editions updated

---
## 2026-07-11 — Super Z / GLM-5.2 (consolidated from LocalMind, Session 8) — rhetorical yes/no questions

- **Flaw:** The Zero-Interruption Principle says "does not ask the user questions between steps," but agents read this as "don't ask for *clarification*" while still asking for *permission* on the default next step. Two models (GLM-5.2 and DeepSeek V4 Flash Free) exhibited the same pattern → it's a protocol gap, not a model trait.
- **Symptom:** GLM-5.2 asked "Want me to proceed with all 5, or just some?" three times in a row, despite the user having repeatedly said "fix everything." The agent proposes → user says yes → agent does it. Should be: agent does it.
- **Root cause:** The Zero-Interruption Principle is stated generally but doesn't explicitly call out asking-for-permission as a failure mode. Agents draw a false distinction between "clarification" (which they know not to ask) and "permission" (which they think is polite).
- **Suggested fix:** Add Pitfall #30: "Don't ask for permission on the default next step. If the action is what the protocol already prescribes, do it and report. Only ask when there's genuine ambiguity."
- **Source:** TisoneK/LocalMind — `.context/flaws/log.md`, Session 8. Originally logged as a DeepSeek-specific observation in Session 3; graduated to a protocol flaw after GLM-5.2 exhibited the same pattern in Session 8.
- **Status:** fixed in this commit — Pitfall #30 added to both editions

---
## 2026-07-11 — Claude Code / claude-fable-5 (package repo session)

- **Flaw:** A review finding was applied without verifying it against the document it cited. The review claimed "the editions have 4 phases, not 5" — both editions have six. The applied fix changed `roles/README.md`'s correct "Phase 5 (Steps 15–17)" to "Phase 4, Steps 15–17", pointing the mandatory memory-update rule at the Report phase (Steps 13–14).
- **Symptom:** `roles/README.md` carried a wrong phase label until the next session re-verified the phase structure (`grep "^### Phase"` in both editions) and reverted it.
- **Root cause:** "Verify before trusting" covers `.context/` entries vs the codebase, but no rule required verifying a review's claims against the referenced file before applying its fixes.
- **Suggested fix:** Pitfall: "Don't apply a review finding without reproducing it — grep the referenced section first."
- **Source:** TisoneK/.context — package repo session, 2026-07-11
- **Status:** fixed in this commit — Phase 5 reference restored + Pitfall #31 added to both editions

---
## 2026-07-11 — Claude Code / claude-opus-4-8 (consolidated from vert, Session 1)

- **Flaw:** The universal kickoff's Step 0 was written cloud-first — PAT setup, cloning the project repo, unconditional `git config`, a token-strip dance on push, and "don't unset `GIT_TOKEN`." A local IDE agent already sitting inside the already-cloned repo had to mentally translate every step, and "clone the project repo" (Step 0b) was a no-op that muddied where to work. Compounding it: the kickoff was a user's local (Desktop) artifact never committed to the package — so a fix to it couldn't reach other users/agents (same pattern as the earlier `QUICKSTART` flaw).
- **Symptom:** During vert Session 1 (a local Claude Code session), the agent had to reconcile the kickoff's clone-based flow against the local protocol edition ("repo is already local, don't clone"), and only avoided the redundant project clone by deferring to the local edition.
- **Root cause:** One kickoff served both editions, but its Step 0 assumed the cloud flow and never branched on "local agent, repo already present." And the kickoff lived only on the user's machine, outside version control.
- **Suggested fix:** (1) Branch Step 0 on agent type — a Local path (confirm you're in the repo, never re-clone, no PAT, don't touch git identity unless empty, clone only the package as a sibling) and a Cloud/sandbox path (the original PAT + clone-both flow); mark every PAT/`GIT_TOKEN` reference cloud-only; normalize paths so `../.context-package` (a sibling of the project) resolves for both. (2) Commit the kickoff into the package so the fix is versioned and shared.
- **Source:** TisoneK/vert — `.context/flaws/log.md`, Session 1 (2026-07-11)
- **Status:** fixed in this commit — `universal-kickoff.md` added to the package with Step 0 branched local/cloud, PAT refs marked cloud-only, a shared `0c. Verify` + path-normalization note, model-identity guidance refined (record an explicit system-prompt model ID rather than only "user fills in"), and a Local-repo-path Pre-Flight field added. Linked from README.

---
## 2026-07-11 — Claude Code / claude-opus-4-8 (consolidated from LocalMind + vert design session)

- **Flaw:** No safe, defined way to propagate *structural* updates (new/changed READMEs, the `flaws/` dir, dedupe rules, etc.) from the package skeleton into already-bootstrapped projects. The only method in practice was copying the skeleton over `.context/`, which overwrites project-owned *data* (session logs, tasks, decisions, user prefs, reviews). Structural updates were hand-carried to each project — tedious, error-prone, and worse with every new project.
- **Symptom:** Throughout the session, every package structural change had to be manually copied into LocalMind; any bulk skeleton copy risked clobbering that project's `.context/` data. Pulling package changes into a parent repo would overwrite data with skeleton stubs.
- **Root cause:** `.context/` never distinguished package-owned *structure* from project-owned *data*, so there was no mechanical, safe sync — every bulk copy was all-or-nothing.
- **Suggested fix:** Make the split explicit with a mechanical **rule** (not a hand-maintained file list): in `context-skeleton/`, a file whose basename is `README.md` or `.gitignore` is structural (sync it); everything else is data (never touch). Ship `SYNC.md` in the skeleton documenting the rule, the two lists, and any non-README structural exceptions. Add a Step 3 sub-step (Path B): reconcile structural files against the skeleton, commit drift as `chore(context): sync structure from package`, never touch data files.
- **Source:** TisoneK/LocalMind (recurring manual sync) + TisoneK/vert design session, 2026-07-11
- **Status:** fixed in this commit — `context-skeleton/SYNC.md` added (rule-first, with the structural/data lists + empty exceptions list); both protocol editions gained the Step 3 structural-sync sub-step, a `SYNC.md` line in the `.context/` structure tree, the 16→17 stub-file count, and Pitfall #33 (don't sync by copying the whole skeleton); skeleton README gained Rule 9 + a file-modes row; package README, QUICKSTART, and `universal-kickoff.md` updated. Detection is by rule so future READMEs sync automatically with no manifest edit.

---
## 2026-07-11 — Claude Code / claude-opus-4-8 (package repo session) — package-clone name inconsistency

- **Flaw:** The docs disagreed on where the package clone lives locally: `QUICKSTART.md` said `~/Code/ai-engineering-protocol`, while `universal-kickoff.md` told agents to clone a sibling named `.context-package`. Neither matched the maintainer's actual convention — name the local clone after the remote repo (`TisoneK/.context` → `.context`). Result: an agent following the kickoff created a second clone (`.context-package`) beside the existing standalone, and the two names drifted.
- **Symptom:** After the vert Session-1 kickoff run, the machine had both `~/Code/ai-engineering-protocol` (standalone) and `~/Code/.context-package` (kickoff-created) — two clones of the same repo under two names, and the standalone fell behind origin because package commits were pushed from the sibling clone.
- **Root cause:** The clone location/name was hardcoded differently in two docs and never aligned to the maintainer's "use the remote repo name" rule.
- **Suggested fix:** Standardize on `.context` (the remote repo name) everywhere: kickoff clones/reuses `../.context` (a sibling), QUICKSTART uses `~/Code/.context`. Add an explicit note that `../.context` (package, one level up) is distinct from a project's in-repo `.context/` memory dir despite the shared basename.
- **Source:** TisoneK/.context — package repo session, 2026-07-11 (raised from vert Session 1)
- **Status:** fixed in this commit — `.context-package` → `.context` across `universal-kickoff.md` and `context-skeleton/SYNC.md`; `QUICKSTART.md` now uses `~/Code/.context`; kickoff carries a package-vs-memory disambiguation note. Standalone clone renamed on disk `ai-engineering-protocol` → `.context`; the redundant `.context-package` clone removed. (Protocol edition filenames `ai-engineering-protocol*.md` are unchanged — only the clone dir name changed.)
