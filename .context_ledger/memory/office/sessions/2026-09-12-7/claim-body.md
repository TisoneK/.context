# Claim — checkin-first (S007, Ines)

Supervisor-reported flaw: the protocol sequences the roster check-in
AFTER the startup read (16 memory files, edition, product code). Two
workers launched together therefore both see an empty board, both take
the same codename/session number, and then meet mid-session wondering
who takes the main tree.

Intended change (docs-only PATCH, core 1.0.6):

1. Check-in becomes the session's FIRST write — sign the board (roster
   + last session entry are the only two files signing needs), push,
   THEN do the deep read of memory / protocol / product code.
2. The push claims the codename: whoever's check-in commit lands first
   keeps the number; on a concurrent collision the later worker edits
   their own row only to the next free codename — never drops a peer's
   row.
3. Main tree settled at the door by conversation: work already in flight
   keeps it; the other worker takes an isolated branch/worktree and both
   declare the shared session/issue before further edits.

Surfaces: both editions (Ten Binding Rules #1, ENTRY carve-out, Step 3
check-in hoist + race rules, multi-agent awareness line), kickoff
template Step 2, AGENTS digest template rule 5 (+ rule 4 clause), roster
template preamble, schema (roster spec + reading order + office
lifecycle), ledger-README template rule 3. VERSION 1.0.6, CHANGELOG
entry, MANIFEST regen, suite green, then self-host + regenerate project
entry points.

Why safe: no tool/port behavior changes, no layout changes, no data
migrations — wording and ordering only, per the PATCH bucket.
