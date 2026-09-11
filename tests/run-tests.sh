#!/bin/sh
# Package test suite for the context-ledger protocol (maintainers; this
# directory is NOT vendored into projects).
#
# Run from anywhere:  sh tests/run-tests.sh
#
# What it covers (core 1.0.1): the gate verdict. A POSIX pipeline reports only
# its last stage's status, so a gated `failing-cmd | tee out.txt` used to pass
# with the tool under test failing (flaw back-ported from a fleet project).
# The suite asserts, on scratch projects, against BOTH editions:
#   - a gated failing command piped into a succeeding consumer fails the gate
#     (via pipefail where the shell supports it, via rejection where it does
#     not -- either way the gate fails);
#   - a gated succeeding pipeline still passes where the verdict is verifiable;
#   - `||` fallbacks and quoted `|` are not rejected on no-pipefail shells;
#   - the PowerShell edition rejects pipelines with two or more external
#     stages (its verdict would be the last native command's exit code) and
#     keeps passing/failing single-native pipelines correctly.
# The ps1 half runs only where a PowerShell engine is on PATH; elsewhere it is
# skipped with a notice.
#
# Exit: 0 all green, 1 any failure.

set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PKG_DIR=$(dirname -- "$SCRIPT_DIR")
CORE=$PKG_DIR/core
PASS=0; FAIL=0

say() { printf '%s\n' "$*"; }
ok()  { PASS=$((PASS + 1)); say "  ok: $1"; }
bad() { FAIL=$((FAIL + 1)); say "  FAIL: $1"; }

# A scratch project: a git repo with a vendored copy of core/bin, so the gate
# tools resolve their own project dir to the scratch, plus a gates.conf. The
# universal pre-commit check needs one commit so `git diff --cached` is clean.
make_scratch() { # $1 = dir
  rm -rf "$1"
  mkdir -p "$1/.context_ledger/core" "$1/.context_ledger/memory/workflows"
  cp -R "$CORE/bin" "$1/.context_ledger/core/bin"
  : > "$1/.context_ledger/memory/workflows/gates.conf"
  git -C "$1" -c init.defaultBranch=main init -q 2>/dev/null || git -C "$1" init -q
  git -C "$1" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
}

set_conf() { # $1 = scratch dir, $2 = one conf line
  printf '%s\n' "$2" > "$1/.context_ledger/memory/workflows/gates.conf"
}

# expect_rc <want:fail|pass> <name> <scratch> <gate invocation...>
expect_rc() {
  _want=$1; _name=$2; _scratch=$3; shift 3
  "$@" > "$_scratch/.test-out.log" 2>&1
  _rc=$?
  case "$_want:$_rc" in
    pass:0)        ok "$_name" ;;
    fail:*)        ok "$_name (rc=$_rc)" ;;
    *) bad "$_name -- rc=$_rc, want $_want"; tail -n 5 "$_scratch/.test-out.log" ;;
  esac
}

say "package tests -- core $(head -n1 "$CORE/VERSION" | tr -d '[:space:]')"

# ---- sh edition -------------------------------------------------------------
SH_SCRATCH=${TMPDIR:-/tmp}/ledger-test-sh
make_scratch "$SH_SCRATCH"
SH_GATE="sh $SH_SCRATCH/.context_ledger/core/bin/ledger-gates run pre-commit"

# The headline case: a gated failing tool piped into a succeeding consumer
# must fail the gate. Passes via pipefail where available, via rejection
# where not -- either way, no silent pass.
set_conf "$SH_SCRATCH" "pre-commit|sh -c 'exit 3' | tee out.txt"
expect_rc fail "sh: gated 'failing-cmd | tee' fails the gate" "$SH_SCRATCH" $SH_GATE

if sh -c 'set -o pipefail' >/dev/null 2>&1 || bash -c 'set -o pipefail' >/dev/null 2>&1; then
  PIPEFAIL_OK=1
  set_conf "$SH_SCRATCH" "pre-commit|sh -c 'exit 0' | tee out.txt"
  expect_rc pass "sh: gated 'ok-cmd | tee' passes (pipefail host)" "$SH_SCRATCH" $SH_GATE
else
  PIPEFAIL_OK=0
  set_conf "$SH_SCRATCH" "pre-commit|sh -c 'exit 0' | tee out.txt"
  expect_rc fail "sh: gated 'ok-cmd | tee' is rejected (no pipefail host)" "$SH_SCRATCH" $SH_GATE
fi

set_conf "$SH_SCRATCH" "pre-commit|sh -c 'exit 3'"
expect_rc fail "sh: plain failing command fails" "$SH_SCRATCH" $SH_GATE

set_conf "$SH_SCRATCH" "pre-commit|sh -c 'exit 0'"
expect_rc pass "sh: plain succeeding command passes" "$SH_SCRATCH" $SH_GATE

# `||` is deliberate fallback semantics -- never rejected, on any shell.
set_conf "$SH_SCRATCH" "pre-commit|sh -c 'exit 3' || sh -c 'exit 0'"
expect_rc pass "sh: '||' fallback is not rejected" "$SH_SCRATCH" $SH_GATE

# A quoted `|` is argument text, not a pipeline -- never rejected.
printf 'a|b\n' > "$SH_SCRATCH/fixture.txt"
set_conf "$SH_SCRATCH" "pre-commit|grep -q 'a|b' fixture.txt"
expect_rc pass "sh: quoted '|' is not rejected" "$SH_SCRATCH" $SH_GATE

# ---- PowerShell edition -----------------------------------------------------
PS_BIN=$(command -v powershell || command -v pwsh) || PS_BIN=""
if [ -z "$PS_BIN" ]; then
  say "  skip: PowerShell edition (no powershell/pwsh on PATH)"
else
  PS_SCRATCH=${TMPDIR:-/tmp}/ledger-test-ps
  make_scratch "$PS_SCRATCH"
  GATE_PS=$PS_SCRATCH/.context_ledger/core/bin/ledger-gates.ps1
  if command -v cygpath >/dev/null 2>&1; then GATE_PS_W=$(cygpath -w "$GATE_PS"); else GATE_PS_W=$GATE_PS; fi
  ps_gate() { "$PS_BIN" -NoProfile -ExecutionPolicy Bypass -File "$GATE_PS_W" run pre-commit; }

  # The case the pre-1.0.1 gate silently passed: two external stages, the
  # tail succeeding. The verdict would be the tail's -- so it is rejected.
  set_conf "$PS_SCRATCH" "pre-commit|cmd /c exit 3 | cmd /c exit 0"
  expect_rc fail "ps: pipeline with two external stages is rejected" "$PS_SCRATCH" ps_gate

  # The literal flaw shape on PowerShell: tee resolves to the Tee-Object
  # cmdlet, one external stage -- runs, and the failing tool's exit code
  # surfaces through \$LASTEXITCODE.
  set_conf "$PS_SCRATCH" "pre-commit|cmd /c exit 3 | Tee-Object out.txt"
  expect_rc fail "ps: gated 'failing-cmd | Tee-Object' fails the gate" "$PS_SCRATCH" ps_gate

  set_conf "$PS_SCRATCH" "pre-commit|cmd /c exit 0 | Tee-Object out.txt"
  expect_rc pass "ps: gated 'ok-cmd | Tee-Object' passes" "$PS_SCRATCH" ps_gate

  set_conf "$PS_SCRATCH" "pre-commit|cmd /c exit 3"
  expect_rc fail "ps: plain failing command fails" "$PS_SCRATCH" ps_gate

  set_conf "$PS_SCRATCH" "pre-commit|cmd /c exit 0"
  expect_rc pass "ps: plain succeeding command passes" "$PS_SCRATCH" ps_gate
fi

rm -rf "$SH_SCRATCH" "$PS_SCRATCH" 2>/dev/null || true

say ""
say "tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
